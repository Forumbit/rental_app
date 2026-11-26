import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';
import '../widgets/listing_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final horizontal = WindowSize.of(context) == WindowSize.compact ? 16.0 : 32.0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: InfiniteScroll(
          onLoadMore: () => ref.read(feedProvider.notifier).loadMore(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                title: Row(
                  children: [
                    Icon(Icons.forest_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(l10n.appTitle),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: ContentWidth(
                  maxWidth: 1400,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
                    child: _Hero(count: feed.value?.items.length),
                  ),
                ),
              ),
              ...switch (feed) {
                AsyncValue(:final value?) when value.items.isEmpty => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.holiday_village_outlined,
                      title: l10n.feedEmptyTitle,
                      body: l10n.feedEmptyBody,
                    ),
                  ),
                ],
                AsyncValue(:final value?) => [
                  _padded(
                    horizontal,
                    ListingGrid(
                      itemCount: value.items.length,
                      itemBuilder: (context, i) {
                        final listing = value.items[i];
                        return ListingCard(
                          listing: listing,
                          onTap: () => context.go('/listings/${listing.id}', extra: listing),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: LoadMoreFooter(
                      loading: value.loadingMore,
                      error: value.loadMoreError,
                      onRetry: () => ref.read(feedProvider.notifier).loadMore(),
                    ),
                  ),
                ],
                AsyncValue(:final error?) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(error: error, onRetry: () => ref.invalidate(feedProvider)),
                  ),
                ],
                _ => [
                  _padded(horizontal, ListingGrid(itemCount: 6, itemBuilder: (_, _) => const ListingCardSkeleton())),
                ],
              },
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _padded(double horizontal, Widget sliver) => CenteredSliver(padding: horizontal, sliver: sliver);
}

class _Hero extends StatelessWidget {
  const _Hero({required this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final compact = WindowSize.of(context) == WindowSize.compact;
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.feedTitle,
                  style: (compact ? theme.textTheme.headlineMedium : theme.textTheme.displaySmall)?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.feedSubtitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (count != null && count! > 0) ...[
                  const SizedBox(height: 16),
                  Chip(
                    avatar: Icon(Icons.verified_outlined, size: 18, color: scheme.primary),
                    label: Text(context.l10n.listingsCount(count!)),
                    backgroundColor: scheme.surface.withValues(alpha: 0.7),
                    side: BorderSide.none,
                  ),
                ],
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 24),
            Icon(Icons.cottage_rounded, size: 120, color: scheme.primary.withValues(alpha: 0.35)),
          ],
        ],
      ),
    );
  }
}

/// Calls [onLoadMore] when the user scrolls near the end.
class InfiniteScroll extends StatelessWidget {
  const InfiniteScroll({super.key, required this.onLoadMore, required this.child});

  final VoidCallback onLoadMore;
  final Widget child;

  @override
  Widget build(BuildContext context) => NotificationListener<ScrollNotification>(
    onNotification: (notification) {
      final metrics = notification.metrics;
      if (metrics.axis == Axis.vertical && metrics.extentAfter < 600) onLoadMore();
      return false;
    },
    child: child,
  );
}

class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({super.key, required this.loading, required this.error, required this.onRetry});

  final bool loading;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('${context.l10n.error(error!)} ${context.l10n.retry}'),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
