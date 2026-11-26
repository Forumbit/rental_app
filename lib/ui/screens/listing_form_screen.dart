import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api_client.dart';
import '../../core/config.dart';
import '../../core/format.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';

/// A photo in the form: already on the server, or picked and not yet uploaded.
class _Photo {
  _Photo.remote(ListingImage this.remote) : bytes = null, name = null, key = 'r${remote.id}';
  _Photo.local(Uint8List this.bytes, String this.name) : remote = null, key = 'l${_seq++}';

  static int _seq = 0;
  ListingImage? remote;
  final Uint8List? bytes;
  final String? name;
  final String key;
}

/// Creates (`id == null`) or edits a listing together with its photos.
class ListingFormScreen extends ConsumerStatefulWidget {
  const ListingFormScreen({super.key, this.id});

  final int? id;

  @override
  ConsumerState<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends ConsumerState<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _country = TextEditingController(text: 'Россия');
  final _region = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _area = TextEditingController();

  var _type = PropertyType.house;
  var _period = PricePeriod.day;
  var _currency = 'RUB';
  var _status = ListingStatus.published;
  int? _bedrooms;
  int? _bathrooms;
  int? _guests;

  final List<_Photo> _photos = [];
  final Set<int> _removed = {};
  Listing? _listing;
  Object? _loadError;
  bool _loading = false;
  bool _dirty = false;
  String? _progress;

  bool get _isNew => widget.id == null;

  @override
  void initState() {
    super.initState();
    if (!_isNew) _load();
  }

  @override
  void dispose() {
    for (final c in [_title, _description, _price, _country, _region, _city, _address, _area]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final listing = await ref.read(listingsRepositoryProvider).mineById(widget.id!);
      _fill(listing);
    } catch (error) {
      _loadError = error;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(Listing listing) {
    final input = listing.input;
    final decimal = (mounted ? context.localeName : 'ru').startsWith('ru') ? ',' : '.';
    _listing = listing;
    _title.text = input.title;
    _description.text = input.description;
    _price.text = (input.priceMinor % 100 == 0)
        ? '${input.priceMinor ~/ 100}'
        : (input.priceMinor / 100).toStringAsFixed(2).replaceAll('.', decimal);
    _country.text = input.country;
    _region.text = input.region ?? '';
    _city.text = input.city;
    _address.text = input.address ?? '';
    final area = input.areaSqm;
    _area.text = area == null
        ? ''
        : (area == area.roundToDouble() ? area.toInt().toString() : area.toString()).replaceAll('.', decimal);
    _type = input.propertyType;
    _period = input.pricePeriod;
    _currency = input.currency;
    _status = input.status;
    _bedrooms = input.bedrooms;
    _bathrooms = input.bathrooms;
    _guests = input.maxGuests;
    _photos
      ..clear()
      ..addAll(listing.images.map(_Photo.remote));
    _removed.clear();
    _dirty = false;
  }

  void _changed() {
    if (!_dirty) setState(() => _dirty = true);
  }

  // ------------------------------------------------------------------ photos

  Future<void> _pickPhotos() async {
    final l10n = context.l10n;
    final remaining = AppConfig.maxImagesPerListing - _photos.length;
    if (remaining <= 0) {
      showMessage(context, l10n.formPhotoLimit(AppConfig.maxImagesPerListing), error: true);
      return;
    }
    // Resizing keeps uploads small and converts HEIC photos to JPEG on iOS.
    final files = await ImagePicker().pickMultiImage(
      maxWidth: 2560,
      maxHeight: 2560,
      imageQuality: 85,
      limit: remaining > 1 ? remaining : null,
    );
    if (files.isEmpty || !mounted) return;
    final added = <_Photo>[];
    for (final file in files.take(remaining)) {
      final bytes = await file.readAsBytes();
      if (bytes.length > AppConfig.maxImageBytes) {
        if (mounted) showMessage(context, l10n.formPhotoTooLarge(file.name), error: true);
        continue;
      }
      added.add(_Photo.local(bytes, file.name));
    }
    if (files.length > remaining && mounted) {
      showMessage(context, l10n.formPhotoLimit(AppConfig.maxImagesPerListing), error: true);
    }
    setState(() {
      _photos.addAll(added);
      _dirty = true;
    });
  }

  void _removePhoto(_Photo photo) {
    setState(() {
      _photos.remove(photo);
      if (photo.remote != null) _removed.add(photo.remote!.id);
      _dirty = true;
    });
  }

  // -------------------------------------------------------------------- save

  ListingInput _input() {
    String? optional(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    final price = double.parse(_price.text.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.'));
    final area = _area.text.trim().isEmpty ? null : double.parse(_area.text.trim().replaceAll(',', '.'));
    return ListingInput(
      title: _title.text.trim(),
      description: _description.text.trim(),
      propertyType: _type,
      priceMinor: (price * 100).round(),
      currency: _currency,
      pricePeriod: _period,
      country: _country.text.trim(),
      region: optional(_region),
      city: _city.text.trim(),
      address: optional(_address),
      areaSqm: area,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      maxGuests: _guests,
      status: _status,
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) {
      showMessage(context, l10n.formRequired, error: true);
      return;
    }
    final repo = ref.read(listingsRepositoryProvider);
    setState(() => _progress = l10n.formSaving);
    Listing? saved;
    try {
      saved = _isNew ? await repo.create(_input()) : await repo.update(widget.id!, _input());
      _listing = saved;
      final id = saved.id;

      for (final imageId in _removed.toList()) {
        try {
          await repo.deleteImage(id, imageId);
        } on ApiException catch (e) {
          if (e.kind != ApiErrorKind.notFound) rethrow;
        }
        _removed.remove(imageId);
      }

      final pending = _photos.where((p) => p.remote == null).toList();
      for (final (i, photo) in pending.indexed) {
        if (mounted) setState(() => _progress = l10n.formUploadingPhoto(i + 1, pending.length));
        // Uploaded photos become remote, so a retry after a failure won't duplicate them.
        photo.remote = await repo.uploadImage(id, photo.bytes!, filename: photo.name!);
      }

      final order = [for (final p in _photos) p.remote!.id];
      final serverOrder = [
        ...saved.images.map((i) => i.id).where((i) => order.contains(i)),
        ...pending.map((p) => p.remote!.id),
      ];
      if (order.isNotEmpty && !listEquals(order, serverOrder)) {
        await repo.reorderImages(id, order);
      }

      invalidateListings(ref);
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _progress = null;
      });
      showMessage(context, l10n.listingSaved);
      context.go('/my');
    } catch (error) {
      if (!mounted) return;
      setState(() => _progress = null);
      if (saved != null) {
        // The listing exists now; further saves must update it, not create another.
        invalidateListings(ref);
        if (_isNew) {
          context.go('/my/${saved.id}/edit');
        }
        showMessage(context, l10n.formPartialSave(l10n.error(error)), error: true);
      } else {
        showMessage(context, l10n.error(error), error: true);
      }
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.deleteListingTitle,
      body: l10n.deleteListingBody(_title.text),
      action: l10n.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(listingsRepositoryProvider).delete(widget.id!);
      invalidateListings(ref);
      if (!mounted) return;
      _dirty = false;
      showMessage(context, l10n.listingDeleted);
      context.go('/my');
    } catch (error) {
      if (mounted) showMessage(context, l10n.error(error), error: true);
    }
  }

  Future<void> _confirmLeave() async {
    final l10n = context.l10n;
    final leave = await confirm(
      context,
      title: l10n.formDiscardTitle,
      body: l10n.formDiscardBody,
      action: l10n.formDiscard,
      destructive: true,
    );
    if (leave && mounted) {
      setState(() => _dirty = false);
      context.go('/my');
    }
  }

  // ---------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final saving = _progress != null;
    final title = Text(_isNew ? l10n.newListing : l10n.editListing);

    if (_loading || _loadError != null) {
      return Scaffold(
        appBar: AppBar(title: title),
        body: _loadError != null
            ? ErrorView(error: _loadError!, onRetry: _load)
            : const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_dirty && !saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !saving) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: title,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close_rounded),
            onPressed: saving ? null : () => _dirty ? _confirmLeave() : context.go('/my'),
          ),
          actions: [
            if (!_isNew)
              IconButton(
                tooltip: l10n.delete,
                onPressed: saving ? null : _delete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            if (_listing?.status == ListingStatus.published)
              IconButton(
                tooltip: l10n.navExplore,
                onPressed: () => context.go('/listings/${_listing!.id}'),
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            const SizedBox(width: 8),
          ],
        ),
        bottomNavigationBar: _SaveBar(progress: _progress, onSave: _save),
        body: Form(
          key: _formKey,
          onChanged: _changed,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: AbsorbPointer(absorbing: saving, child: _fields(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fields(BuildContext context) {
    final l10n = context.l10n;
    String? required(String? v) => (v == null || v.trim().isEmpty) ? l10n.formRequired : null;
    String? Function(String?) maxLength(int max, {bool req = false}) => (v) {
      if (req && required(v) != null) return l10n.formRequired;
      return (v?.trim().length ?? 0) > max ? l10n.formTooLong(max) : null;
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormSection(
          icon: Icons.photo_library_outlined,
          title: l10n.formSectionPhotos,
          subtitle: l10n.formPhotosHint(AppConfig.maxImagesPerListing),
          child: _PhotoStrip(
            photos: _photos,
            onAdd: _photos.length < AppConfig.maxImagesPerListing ? _pickPhotos : null,
            onRemove: _removePhoto,
            onReorder: (from, to) => setState(() {
              _photos.insert(to, _photos.removeAt(from));
              _dirty = true;
            }),
          ),
        ),
        _FormSection(
          icon: Icons.home_outlined,
          title: l10n.formSectionMain,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.formPropertyType, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in PropertyType.values)
                    ChoiceChip(
                      // The icon already marks the choice; a checkmark would cover it.
                      showCheckmark: false,
                      avatar: Icon(switch (type) {
                        PropertyType.house => Icons.house_outlined,
                        PropertyType.cottage => Icons.cottage_outlined,
                        PropertyType.dacha => Icons.yard_outlined,
                        PropertyType.apartment => Icons.apartment_outlined,
                      }),
                      label: Text(l10n.propertyType(type)),
                      selected: _type == type,
                      onSelected: (_) => setState(() {
                        _type = type;
                        _dirty = true;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.formTitle, hintText: l10n.formTitleHint),
                validator: maxLength(200, req: true),
                maxLength: 200,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                minLines: 4,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: l10n.formDescription,
                  hintText: l10n.formDescriptionHint,
                  alignLabelWithHint: true,
                ),
                validator: required,
              ),
            ],
          ),
        ),
        _FormSection(
          icon: Icons.payments_outlined,
          title: l10n.formSectionPrice,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,\s]'))],
                      decoration: InputDecoration(labelText: l10n.formPrice),
                      validator: (v) {
                        if (required(v) != null) return l10n.formRequired;
                        final value = double.tryParse(v!.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.'));
                        if (value == null) return l10n.formInvalidNumber;
                        return value <= 0 ? l10n.formPricePositive : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      decoration: InputDecoration(labelText: l10n.formCurrency),
                      items: [
                        for (final c in const ['RUB', 'USD', 'EUR']) DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: (v) => setState(() => _currency = v ?? 'RUB'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentedButton<PricePeriod>(
                segments: [
                  for (final p in PricePeriod.values)
                    ButtonSegment(value: p, label: Text('${l10n.formPeriod} ${l10n.period(p)}')),
                ],
                selected: {_period},
                onSelectionChanged: (s) => setState(() {
                  _period = s.first;
                  _dirty = true;
                }),
              ),
            ],
          ),
        ),
        _FormSection(
          icon: Icons.place_outlined,
          title: l10n.formSectionLocation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TwoColumns(
                first: TextFormField(
                  controller: _city,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.formCity),
                  validator: maxLength(150, req: true),
                ),
                second: TextFormField(
                  controller: _region,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l10n.formRegion),
                  validator: maxLength(150),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.formAddress, helperText: l10n.formAddressHint),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _country,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.formCountry),
                validator: maxLength(100, req: true),
              ),
            ],
          ),
        ),
        _FormSection(
          icon: Icons.tune_rounded,
          title: l10n.formSectionDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Counter(
                icon: Icons.people_outline_rounded,
                label: l10n.formMaxGuests,
                value: _guests,
                min: 1,
                onChanged: (v) => setState(() {
                  _guests = v;
                  _dirty = true;
                }),
              ),
              _Counter(
                icon: Icons.bed_outlined,
                label: l10n.formBedrooms,
                value: _bedrooms,
                onChanged: (v) => setState(() {
                  _bedrooms = v;
                  _dirty = true;
                }),
              ),
              _Counter(
                icon: Icons.bathtub_outlined,
                label: l10n.formBathrooms,
                value: _bathrooms,
                onChanged: (v) => setState(() {
                  _bathrooms = v;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _area,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                decoration: InputDecoration(
                  labelText: l10n.formArea,
                  prefixIcon: const Icon(Icons.square_foot_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final value = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (value == null) return l10n.formInvalidNumber;
                  return value < 0.01 || value > 999999.99 ? l10n.formAreaRange : null;
                },
              ),
            ],
          ),
        ),
        _FormSection(
          icon: Icons.visibility_outlined,
          title: l10n.formSectionVisibility,
          subtitle: l10n.formStatusHint,
          child: SegmentedButton<ListingStatus>(
            segments: [for (final s in ListingStatus.values) ButtonSegment(value: s, label: Text(l10n.status(s)))],
            selected: {_status},
            onSelectionChanged: (s) => setState(() {
              _status = s.first;
              _dirty = true;
            }),
          ),
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.icon, required this.title, required this.child, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(title, style: theme.textTheme.titleMedium),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Side by side on wide forms, stacked on phones.
class _TwoColumns extends StatelessWidget {
  const _TwoColumns({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth < 480
        ? Column(children: [first, const SizedBox(height: 16), second])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          ),
  );
}

/// Optional integer with − / + buttons; "—" means not specified.
class _Counter extends StatelessWidget {
  const _Counter({required this.icon, required this.label, required this.value, required this.onChanged, this.min = 0});

  final IconData icon;
  final String label;
  final int? value;
  final int min;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          IconButton.outlined(
            onPressed: value == null ? null : () => onChanged(value! <= min ? null : value! - 1),
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 44,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                value?.toString() ?? '—',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          IconButton.outlined(
            onPressed: (value ?? 0) >= 99 ? null : () => onChanged(value == null ? min.clamp(1, 99) : value! + 1),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.photos, required this.onAdd, required this.onRemove, required this.onReorder});

  final List<_Photo> photos;
  final VoidCallback? onAdd;
  final ValueChanged<_Photo> onRemove;
  final ReorderCallback onReorder;

  static const _height = 128.0;
  static const _width = 170.0;

  @override
  Widget build(BuildContext context) {
    final touch = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
    return SizedBox(
      height: _height,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        itemCount: photos.length,
        onReorderItem: onReorder,
        proxyDecorator: (child, _, animation) => ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.05).animate(animation),
          child: Material(elevation: 8, borderRadius: BorderRadius.circular(16), child: child),
        ),
        footer: _AddTile(onTap: onAdd, width: _width),
        itemBuilder: (context, i) {
          final photo = photos[i];
          final tile = _PhotoTile(photo: photo, cover: i == 0, onRemove: () => onRemove(photo), width: _width);
          return Padding(
            key: ValueKey(photo.key),
            padding: const EdgeInsets.only(right: 10),
            child: touch
                ? ReorderableDelayedDragStartListener(index: i, child: tile)
                : ReorderableDragStartListener(index: i, child: tile),
          );
        },
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.cover, required this.onRemove, required this.width});

  final _Photo photo;
  final bool cover;
  final VoidCallback onRemove;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            photo.remote != null
                ? AppNetworkImage(photo.remote!.fullUrl, memCacheWidth: 400)
                : Image.memory(photo.bytes!, fit: BoxFit.cover, cacheWidth: 400),
            if (cover)
              Positioned(
                left: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: Text(
                      context.l10n.formCover,
                      style: TextStyle(color: scheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            if (photo.remote == null)
              Positioned(
                left: 8,
                top: 8,
                child: Icon(Icons.cloud_upload_outlined, color: Colors.white, shadows: const [Shadow(blurRadius: 6)]),
              ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                tooltip: context.l10n.delete,
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap, required this.width});

  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Material(
        color: onTap == null ? scheme.surfaceContainerHighest : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 32, color: scheme.onPrimaryContainer),
              const SizedBox(height: 8),
              Text(
                context.l10n.formAddPhotos,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.progress, required this.onSave});

  final String? progress;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final saving = progress != null;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Center(
            // Without heightFactor the bar would expand to the whole screen.
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Icon(Icons.check_rounded),
                  label: Text(progress ?? context.l10n.save),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
