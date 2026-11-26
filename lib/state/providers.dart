import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../data/models.dart';
import '../data/repositories.dart';

/// Overridden in main() once preferences are loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override sharedPreferencesProvider'),
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(TokenStorage()));

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(apiClientProvider)));

final listingsRepositoryProvider = Provider((ref) => ListingsRepository(ref.watch(apiClientProvider)));

// ---------------------------------------------------------------- settings

class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;

  /// null follows the device language.
  final Locale? locale;
}

class SettingsController extends Notifier<AppSettings> {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final theme = ThemeMode.values.asNameMap()[_prefs.getString(_themeKey)] ?? ThemeMode.system;
    final locale = _prefs.getString(_localeKey);
    return AppSettings(themeMode: theme, locale: locale == null ? null : Locale(locale));
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setString(_themeKey, mode.name);
    state = AppSettings(themeMode: mode, locale: state.locale);
  }

  void setLocale(Locale? locale) {
    locale == null ? _prefs.remove(_localeKey) : _prefs.setString(_localeKey, locale.languageCode);
    state = AppSettings(themeMode: state.themeMode, locale: locale);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

// -------------------------------------------------------------------- auth

/// The signed-in user, or null for a guest.
class AuthController extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() async {
    final expired = _repo.sessionExpired.listen((_) => state = const AsyncData(null));
    ref.onDispose(expired.cancel);

    await _repo.restoreSession();
    if (!_repo.hasSession) return null;
    try {
      return await _repo.me();
    } on ApiException catch (e) {
      // Offline start: keep tokens and let the user retry; otherwise sign out.
      if (e.kind == ApiErrorKind.network) rethrow;
      await _repo.logout();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    final user = await _repo.login(email.trim().toLowerCase(), password);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthController, User?>(AuthController.new);

// ---------------------------------------------------------------- listings

/// State of an infinitely scrolled list.
class PagedListings {
  const PagedListings({
    this.items = const [],
    this.nextCursor,
    this.hasMore = true,
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<Listing> items;
  final int? nextCursor;
  final bool hasMore;
  final bool loadingMore;
  final Object? loadMoreError;

  PagedListings append(ListingPage page) =>
      PagedListings(items: [...items, ...page.items], nextCursor: page.nextCursor, hasMore: page.nextCursor != null);

  PagedListings copyWith({List<Listing>? items, bool? loadingMore, Object? loadMoreError}) => PagedListings(
    items: items ?? this.items,
    nextCursor: nextCursor,
    hasMore: hasMore,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreError: loadMoreError,
  );
}

abstract class PagedListingsController extends AsyncNotifier<PagedListings> {
  Future<ListingPage> fetch(int? cursor);

  @override
  Future<PagedListings> build() async => const PagedListings().append(await fetch(null));

  Future<void> refresh() async {
    final page = await fetch(null);
    state = AsyncData(const PagedListings().append(page));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final page = await fetch(current.nextCursor);
      state = AsyncData(current.append(page));
    } catch (error) {
      state = AsyncData(current.copyWith(loadingMore: false, loadMoreError: error));
    }
  }

  /// Replaces or removes a listing after a local change, without refetching.
  void patch(int id, Listing? updated) {
    final current = state.value;
    if (current == null) return;
    final items = [
      for (final item in current.items)
        if (item.id != id) item else ?updated,
    ];
    state = AsyncData(current.copyWith(items: items));
  }
}

class FeedController extends PagedListingsController {
  @override
  Future<ListingPage> fetch(int? cursor) => ref.read(listingsRepositoryProvider).published(cursor: cursor);
}

final feedProvider = AsyncNotifierProvider<FeedController, PagedListings>(FeedController.new);

/// The author's listings, optionally filtered by status (null = all).
class MyListingsController extends PagedListingsController {
  MyListingsController(this.status);

  final ListingStatus? status;

  @override
  Future<ListingPage> fetch(int? cursor) => ref.read(listingsRepositoryProvider).mine(status: status, cursor: cursor);

  @override
  Future<PagedListings> build() {
    // Reload when another account signs in.
    ref.watch(authProvider.select((auth) => auth.value?.id));
    return super.build();
  }
}

final myListingsProvider = AsyncNotifierProvider.autoDispose
    .family<MyListingsController, PagedListings, ListingStatus?>(MyListingsController.new);

final publishedListingProvider = FutureProvider.autoDispose.family<Listing, int>(
  (ref, id) => ref.read(listingsRepositoryProvider).publishedById(id),
);

final ownListingProvider = FutureProvider.autoDispose.family<Listing, int>(
  (ref, id) => ref.read(listingsRepositoryProvider).mineById(id),
);

/// Refreshes every list that may show a listing after it changed.
void invalidateListings(WidgetRef ref) {
  ref.invalidate(feedProvider);
  ref.invalidate(myListingsProvider);
  ref.invalidate(publishedListingProvider);
  ref.invalidate(ownListingProvider);
}
