import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/providers.dart';
import 'screens/auth_screens.dart';
import 'screens/feed_screen.dart';
import 'screens/listing_details_screen.dart';
import 'screens/listing_form_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/common.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever the signed-in user changes.
  final authChanges = ValueNotifier(0);
  ref.listen(authProvider, (_, _) => authChanges.value++);
  ref.onDispose(authChanges.dispose);

  return GoRouter(
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading && !auth.hasValue) return null;
      final signedIn = auth.value != null;
      final path = state.matchedLocation;
      final needsAccount = path == '/my/new' || (path.startsWith('/my/') && path.endsWith('/edit'));
      if (needsAccount && !signedIn) {
        return Uri(path: '/login', queryParameters: {'from': state.uri.toString()}).toString();
      }
      if (signedIn && (path == '/login' || path == '/register')) return '/my';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.explore_off_outlined,
        title: context.l10n.notFoundTitle,
        action: FilledButton(onPressed: () => context.go('/'), child: Text(context.l10n.navExplore)),
      ),
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const FeedScreen(),
                routes: [
                  GoRoute(
                    path: 'listings/:id',
                    builder: (_, state) => ListingDetailsScreen(
                      id: int.tryParse(state.pathParameters['id']!) ?? 0,
                      initial: state.extra is Listing ? state.extra! as Listing : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my',
                builder: (_, _) => const _AccountGate(child: MyListingsScreen()),
                routes: [
                  GoRoute(path: 'new', builder: (_, _) => const ListingFormScreen()),
                  GoRoute(
                    path: ':id/edit',
                    builder: (_, state) => ListingFormScreen(
                      key: ValueKey(state.pathParameters['id']),
                      id: int.tryParse(state.pathParameters['id']!) ?? 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (_, state) =>
            LoginScreen(from: state.uri.queryParameters['from'], email: state.uri.queryParameters['email']),
      ),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/verify',
        builder: (_, state) => VerifyEmailScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
    ],
  );
});

/// Shows a sign-in prompt to guests instead of an account-only screen.
class _AccountGate extends ConsumerWidget {
  const _AccountGate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isLoading && !auth.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.value == null ? const SignInPrompt(from: '/my') : child;
  }
}

/// Bottom navigation on phones, a rail on tablets and an extended rail on desktops.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabRoots = {'/', '/my', '/profile'};

  void _select(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = WindowSize.of(context);
    final destinations = [
      (Icons.travel_explore_outlined, Icons.travel_explore_rounded, l10n.navExplore),
      (Icons.holiday_village_outlined, Icons.holiday_village_rounded, l10n.navMyListings),
      (Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
    ];

    if (size == WindowSize.compact) {
      // Nested screens (details, forms) get the full height.
      final atRoot = _tabRoots.contains(GoRouterState.of(context).uri.path);
      return Scaffold(
        body: shell,
        bottomNavigationBar: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: atRoot
              ? NavigationBar(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: _select,
                  destinations: [
                    for (final (icon, selected, label) in destinations)
                      NavigationDestination(icon: Icon(icon), selectedIcon: Icon(selected), label: label),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      );
    }

    final extended = size == WindowSize.expanded;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            minExtendedWidth: 232,
            labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _select,
            leading: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.forest_rounded, size: 32, color: scheme.primary),
                      if (extended) ...[
                        const SizedBox(width: 10),
                        Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  extended
                      ? FloatingActionButton.extended(
                          elevation: 0,
                          onPressed: () => context.go('/my/new'),
                          icon: const Icon(Icons.add_home_outlined),
                          label: Text(l10n.newListing),
                        )
                      : FloatingActionButton(
                          elevation: 0,
                          tooltip: l10n.newListing,
                          onPressed: () => context.go('/my/new'),
                          child: const Icon(Icons.add_home_outlined),
                        ),
                ],
              ),
            ),
            destinations: [
              for (final (icon, selected, label) in destinations)
                NavigationRailDestination(icon: Icon(icon), selectedIcon: Icon(selected), label: Text(label)),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: shell),
        ],
      ),
    );
  }
}
