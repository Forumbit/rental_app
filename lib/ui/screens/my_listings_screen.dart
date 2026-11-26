import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../widgets/common.dart';
import '../widgets/listing_card.dart';
import 'feed_screen.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  ListingStatus? _status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = myListingsProvider(_status);
    final listings = ref.watch(provider);
    final compact = WindowSize.of(context) == WindowSize.compact;
    final horizontal = compact ? 16.0 : 32.0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/my/new'),
        icon: const Icon(Icons.add_home_outlined),
        label: Text(l10n.newListing),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(provider.notifier).refresh(),
        child: InfiniteScroll(
          onLoadMore: () => ref.read(provider.notifier).loadMore(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(floating: true, title: Text(l10n.navMyListings)),
              CenteredSliver(
                padding: horizontal,
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        for (final status in [null, ...ListingStatus.values])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(l10n.status(status)),
                              selected: _status == status,
                              onSelected: (_) => setState(() => _status = status),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              ...switch (listings) {
                AsyncValue(:final value?) when value.items.isEmpty => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _status == null
                        ? EmptyState(
                            icon: Icons.add_home_work_outlined,
                            title: l10n.myListingsEmptyTitle,
                            body: l10n.myListingsEmptyBody,
                            action: FilledButton.icon(
                              onPressed: () => context.go('/my/new'),
                              icon: const Icon(Icons.add_rounded),
                              label: Text(l10n.newListing),
                            ),
                          )
                        : EmptyState(icon: Icons.filter_list_off_rounded, title: l10n.myListingsFilterEmpty),
                  ),
                ],
                AsyncValue(:final value?) => [
                  CenteredSliver(
                    padding: horizontal,
                    sliver: ListingGrid(
                      itemCount: value.items.length,
                      itemBuilder: (context, i) {
                        final listing = value.items[i];
                        return ListingCard(
                          listing: listing,
                          showStatus: true,
                          onTap: () => context.go('/my/${listing.id}/edit'),
                          menu: _ListingMenu(listing: listing),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: LoadMoreFooter(
                      loading: value.loadingMore,
                      error: value.loadMoreError,
                      onRetry: () => ref.read(provider.notifier).loadMore(),
                    ),
                  ),
                ],
                AsyncValue(:final error?) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(error: error, onRetry: () => ref.invalidate(provider)),
                  ),
                ],
                _ => [
                  CenteredSliver(
                    padding: horizontal,
                    sliver: ListingGrid(itemCount: 3, itemBuilder: (_, _) => const ListingCardSkeleton()),
                  ),
                ],
              },
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Action { edit, view, publish, unpublish, delete }

class _ListingMenu extends ConsumerWidget {
  const _ListingMenu({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final published = listing.status == ListingStatus.published;
    return PopupMenuButton<_Action>(
      icon: const Icon(Icons.more_vert_rounded),
      style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9)),
      onSelected: (action) => _run(context, ref, action),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _Action.edit,
          child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(l10n.edit)),
        ),
        if (published)
          PopupMenuItem(
            value: _Action.view,
            child: ListTile(leading: const Icon(Icons.open_in_new_rounded), title: Text(l10n.navExplore)),
          ),
        PopupMenuItem(
          value: published ? _Action.unpublish : _Action.publish,
          child: ListTile(
            leading: Icon(published ? Icons.visibility_off_outlined : Icons.public_rounded),
            title: Text(published ? l10n.unpublish : l10n.publish),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _Action.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
            title: Text(l10n.delete),
          ),
        ),
      ],
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, _Action action) async {
    final l10n = context.l10n;
    final repo = ref.read(listingsRepositoryProvider);
    try {
      switch (action) {
        case _Action.edit:
          context.go('/my/${listing.id}/edit');
        case _Action.view:
          context.go('/listings/${listing.id}', extra: listing);
        case _Action.publish || _Action.unpublish:
          final status = action == _Action.publish ? ListingStatus.published : ListingStatus.draft;
          await repo.update(listing.id, listing.input.copyWith(status: status));
          invalidateListings(ref);
          if (context.mounted) {
            showMessage(context, action == _Action.publish ? l10n.listingPublished : l10n.listingUnpublished);
          }
        case _Action.delete:
          final ok = await confirm(
            context,
            title: l10n.deleteListingTitle,
            body: l10n.deleteListingBody(listing.title),
            action: l10n.delete,
            destructive: true,
          );
          if (!ok) return;
          await repo.delete(listing.id);
          invalidateListings(ref);
          if (context.mounted) showMessage(context, l10n.listingDeleted);
      }
    } catch (error) {
      if (context.mounted) showMessage(context, l10n.error(error), error: true);
    }
  }
}
