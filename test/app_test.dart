import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rental_app/core/api_client.dart';
import 'package:rental_app/core/theme.dart';
import 'package:rental_app/data/models.dart';
import 'package:rental_app/data/repositories.dart';
import 'package:rental_app/main.dart';
import 'package:rental_app/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client_test.dart' show MemoryTokenStorage;
import 'models_test.dart' show listingJson;

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(ApiClient(MemoryTokenStorage()));

  @override
  Future<void> restoreSession() async {}

  @override
  bool get hasSession => false;
}

class FakeListingsRepository extends ListingsRepository {
  FakeListingsRepository(this.items) : super(ApiClient(MemoryTokenStorage()));

  final List<Listing> items;

  @override
  Future<ListingPage> published({int? cursor}) async => ListingPage(items: items, nextCursor: null);

  @override
  Future<Listing> publishedById(int id) async => items.firstWhere((l) => l.id == id);
}

Listing listing(int id, String title) => Listing.fromJson({...listingJson(), 'id': id, 'title': title});

Future<void> pumpApp(WidgetTester tester, {required Size size, List<Listing>? items}) async {
  AppTheme.useGoogleFonts = false;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        listingsRepositoryProvider.overrideWithValue(
          FakeListingsRepository(items ?? [listing(1, 'Lake house'), listing(2, 'City loft')]),
        ),
      ],
      retry: (_, _) => null,
      child: const RentalApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phone: feed, bottom navigation and guest prompt', (tester) async {
    await pumpApp(tester, size: const Size(400, 860));

    expect(find.text('Find your place to stay'), findsOneWidget);
    expect(find.text('Lake house'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    await tester.tap(find.text('My listings'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to continue'), findsOneWidget);
  });

  testWidgets('desktop: navigation rail with a create button', (tester) async {
    await pumpApp(tester, size: const Size(1400, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('New listing'), findsOneWidget);
    expect(find.text('City loft'), findsOneWidget);
  });

  testWidgets('opens listing details and hides the bottom bar', (tester) async {
    await pumpApp(tester, size: const Size(400, 860));

    await tester.tap(find.text('Lake house'));
    await tester.pumpAndSettle();
    expect(find.text('Description'), findsNothing);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Contact the owner'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('switches language and theme in the profile', (tester) async {
    await pumpApp(tester, size: const Size(400, 860));

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Профиль'), findsWidgets);
    expect(find.text('Настройки'), findsOneWidget);

    await tester.tap(find.text('Тёмная'));
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('empty feed shows a friendly empty state', (tester) async {
    await pumpApp(tester, size: const Size(400, 860), items: []);
    expect(find.text('No listings yet'), findsOneWidget);
  });
}
