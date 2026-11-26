import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';
import '../widgets/gallery.dart';
import '../widgets/listing_card.dart';

/// Public listing page. [initial] (passed from a card) renders instantly while
/// the fresh copy loads.
class ListingDetailsScreen extends ConsumerWidget {
  const ListingDetailsScreen({super.key, required this.id, this.initial});

  final int id;
  final Listing? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publishedListingProvider(id));
    final listing = async.value ?? initial;

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: async.hasError
            ? ErrorView(error: async.error!, onRetry: () => ref.invalidate(publishedListingProvider(id)))
            : const Center(child: CircularProgressIndicator()),
      );
    }

    final wide = MediaQuery.sizeOf(context).width >= 960;
    return wide ? _WideLayout(listing: listing) : _CompactLayout(listing: listing);
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            // 4:3 photo, but not taller than 60% of the screen on tablets.
            expandedHeight: math.min(width * 3 / 4, MediaQuery.sizeOf(context).height * 0.6),
            leading: const _CircleBack(),
            flexibleSpace: FlexibleSpaceBar(
              background: Gallery(images: listing.images, heroTag: 'listing-cover-${listing.id}'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            // The price lives in the bottom bar here.
            sliver: SliverToBoxAdapter(child: _Info(listing: listing, showPrice: false)),
          ),
        ],
      ),
      bottomNavigationBar: _BookingBar(listing: listing),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listing.title, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 48),
        child: ContentWidth(
          maxWidth: 1240,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Gallery(
                        images: listing.images,
                        heroTag: 'listing-cover-${listing.id}',
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Info(listing: listing, showPrice: false),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: _PriceCard(listing: listing)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.listing, this.showPrice = true});

  final Listing listing;
  final bool showPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final input = listing.input;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            Chip(avatar: const Icon(Icons.home_outlined, size: 18), label: Text(l10n.propertyType(input.propertyType))),
          ],
        ),
        const SizedBox(height: 12),
        Text(listing.title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.place_outlined, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Expanded(child: Text(listing.location, style: theme.textTheme.titleSmall)),
          ],
        ),
        if (showPrice) ...[const SizedBox(height: 16), PriceText(input: input, large: true)],
        _OwnerBanner(listing: listing),
        const SizedBox(height: 28),
        _Section(
          title: l10n.detailsFeatures,
          child: ListingFacts(input: input),
        ),
        _Section(title: l10n.detailsAbout, child: _ExpandableText(input.description)),
        _Section(
          title: l10n.detailsLocation,
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(Icons.map_outlined, color: theme.colorScheme.onPrimaryContainer),
              ),
              title: Text([input.city, if (input.address?.isNotEmpty ?? false) input.address!].join(', ')),
              subtitle: Text([if (input.region?.isNotEmpty ?? false) input.region!, input.country].join(', ')),
            ),
          ),
        ),
        if (listing.publishedAt != null)
          Text(
            l10n.detailsPublished(Formatters.date(listing.publishedAt!, context.localeName)),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _OwnerBanner extends ConsumerWidget {
  const _OwnerBanner({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider.select((auth) => auth.value?.id));
    if (userId != listing.ownerId) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Material(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(Icons.verified_user_outlined, color: scheme.onSecondaryContainer),
          title: Text(context.l10n.detailsYourListing),
          trailing: FilledButton.tonalIcon(
            onPressed: () => context.go('/my/${listing.id}/edit'),
            icon: const Icon(Icons.edit_outlined),
            label: Text(context.l10n.edit),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText(this.text);

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55);
    final long = widget.text.length > 320;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            style: style,
            maxLines: long && !_expanded ? 6 : null,
            overflow: long && !_expanded ? TextOverflow.fade : null,
          ),
        ),
        if (long)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? context.l10n.detailsShowLess : context.l10n.detailsShowMore),
          ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PriceText(input: listing.input, large: true),
            const SizedBox(height: 16),
            ListingFacts(input: listing.input, compact: true),
            const SizedBox(height: 24),
            const _ContactButton(),
          ],
        ),
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: PriceText(input: listing.input),
                ),
              ),
              const SizedBox(width: 12),
              const _ContactButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton();

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: () => showMessage(context, context.l10n.detailsContactSoon),
    icon: const Icon(Icons.chat_bubble_outline_rounded),
    label: Text(context.l10n.detailsContact),
  );
}

class _CircleBack extends StatelessWidget {
  const _CircleBack();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: IconButton.filledTonal(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => context.canPop() ? context.pop() : context.go('/'),
      icon: const Icon(Icons.arrow_back_rounded),
    ),
  );
}
