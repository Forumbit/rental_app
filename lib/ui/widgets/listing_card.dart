import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import 'common.dart';

/// Grid card: cover photo, type badge, title, location, key facts and price.
class ListingCard extends StatefulWidget {
  const ListingCard({super.key, required this.listing, required this.onTap, this.showStatus = false, this.menu});

  final Listing listing;
  final VoidCallback onTap;
  final bool showStatus;
  final Widget? menu;

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final listing = widget.listing;
    final input = listing.input;
    final cover = listing.cover;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Card(
          elevation: _hovered ? 6 : 0,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.25),
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'listing-cover-${listing.id}',
                        child: cover == null
                            ? ColoredBox(
                                color: theme.colorScheme.secondaryContainer,
                                child: Icon(
                                  Icons.home_work_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              )
                            : AppNetworkImage(cover.fullUrl, memCacheWidth: 900),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Wrap(
                          spacing: 6,
                          children: [
                            _Badge(text: l10n.propertyType(input.propertyType)),
                            if (widget.showStatus) StatusBadge(status: listing.status),
                          ],
                        ),
                      ),
                      if (listing.images.length > 1)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: _Badge(text: '${listing.images.length}', icon: Icons.photo_library_outlined),
                        ),
                      if (widget.menu != null) Positioned(right: 4, top: 4, child: widget.menu!),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              listing.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListingFacts(input: input, compact: true),
                      const SizedBox(height: 12),
                      PriceText(input: input),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PriceText extends StatelessWidget {
  const PriceText({super.key, required this.input, this.large = false});

  final ListingInput input;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = Formatters.price(input.priceMinor, input.currency, context.localeName);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: price,
            style: (large ? theme.textTheme.headlineSmall : theme.textTheme.titleMedium)?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: ' / ${context.l10n.period(input.pricePeriod)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Guests, bedrooms, area — only the ones the owner filled in.
class ListingFacts extends StatelessWidget {
  const ListingFacts({super.key, required this.input, this.compact = false});

  final ListingInput input;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final facts = <(IconData, String)>[
      if (input.maxGuests != null) (Icons.people_outline_rounded, l10n.guests(input.maxGuests!)),
      if (input.bedrooms != null) (Icons.bed_outlined, l10n.bedrooms(input.bedrooms!)),
      if (!compact && input.bathrooms != null) (Icons.bathtub_outlined, l10n.bathrooms(input.bathrooms!)),
      if (input.areaSqm != null)
        (Icons.square_foot_rounded, l10n.areaSqm(Formatters.number(input.areaSqm!, context.localeName))),
    ];
    if (facts.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Wrap(
      spacing: compact ? 12 : 10,
      runSpacing: 8,
      children: [
        for (final (icon, text) in facts)
          compact
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(text, style: theme.textTheme.bodySmall),
                  ],
                )
              : Chip(avatar: Icon(icon, size: 18), label: Text(text)),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (status) {
      ListingStatus.published => (scheme.primary, scheme.onPrimary, Icons.public_rounded),
      ListingStatus.draft => (scheme.tertiaryContainer, scheme.onTertiaryContainer, Icons.edit_note_rounded),
      ListingStatus.archived => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant, Icons.inventory_2_outlined),
    };
    return _Badge(text: context.l10n.status(status), icon: icon, background: background, foreground: foreground);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.icon, this.background, this.foreground});

  final String text;
  final IconData? icon;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = foreground ?? theme.colorScheme.onSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
            Text(
              text,
              style: theme.textTheme.labelMedium?.copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder card shown while the first page loads.
class ListingCardSkeleton extends StatelessWidget {
  const ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Skeleton()),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(height: 18, width: 200, radius: 6),
              SizedBox(height: 10),
              Skeleton(height: 14, width: 140, radius: 6),
              SizedBox(height: 14),
              Skeleton(height: 18, width: 110, radius: 6),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Responsive grid of listings with infinite scroll footer.
class ListingGrid extends StatelessWidget {
  const ListingGrid({super.key, required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = width < 560 ? 1 : (width < 900 ? 2 : (width < 1240 ? 3 : 4));
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            // Photo is about 4:3 of the tile width; the text block grows with
            // the system font size and the photo absorbs any difference.
            mainAxisExtent: (width - 20 * (columns - 1)) / columns * 3 / 4 + 172 * textScale,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
