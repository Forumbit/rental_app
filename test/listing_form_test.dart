import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rental_app/core/api_client.dart';
import 'package:rental_app/core/theme.dart';
import 'package:rental_app/data/models.dart';
import 'package:rental_app/data/repositories.dart';
import 'package:rental_app/l10n/app_localizations.dart';
import 'package:rental_app/state/providers.dart';
import 'package:rental_app/ui/screens/listing_form_screen.dart';

import 'api_client_test.dart' show MemoryTokenStorage;
import 'models_test.dart' show listingJson;

class RecordingRepository extends ListingsRepository {
  RecordingRepository() : super(ApiClient(MemoryTokenStorage()));

  ListingInput? created;

  @override
  Future<Listing> create(ListingInput input) async {
    created = input;
    return Listing.fromJson({...listingJson(), 'id': 42, 'images': <Object>[]});
  }
}

Future<RecordingRepository> pumpForm(WidgetTester tester) async {
  AppTheme.useGoogleFonts = false;
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = RecordingRepository();
  final router = GoRouter(
    initialLocation: '/my/new',
    routes: [
      GoRoute(
        path: '/my',
        builder: (_, _) => const Scaffold(body: Text('MY LISTINGS')),
      ),
      GoRoute(path: '/my/new', builder: (_, _) => const ListingFormScreen()),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [listingsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  testWidgets('validates required fields before calling the API', (tester) async {
    final repo = await pumpForm(tester);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);
    expect(repo.created, isNull);
  });

  testWidgets('creates a listing with converted values and returns to my listings', (tester) async {
    final repo = await pumpForm(tester);

    await tester.tap(find.text('Cottage'));
    await tester.enterText(field('Title'), '  Lake house  ');
    await tester.enterText(field('Description'), 'Sauna and a pier');
    await tester.enterText(field('Price'), '8500,50');
    await tester.enterText(field('City or village'), 'Istra');
    await tester.enterText(field('Area, m²'), '96,5');
    await tester.tap(find.text('Per month'));
    // Guests: "—" until the first tap, then starts at 1.
    final guestsPlus = find.descendant(
      of: find.ancestor(of: find.text('Guests'), matching: find.byType(Row)).first,
      matching: find.byIcon(Icons.add_rounded),
    );
    await tester.tap(guestsPlus);
    await tester.pump();
    await tester.tap(guestsPlus);
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final input = repo.created!;
    expect(input.title, 'Lake house');
    expect(input.propertyType, PropertyType.cottage);
    expect(input.priceMinor, 850050);
    expect(input.pricePeriod, PricePeriod.month);
    expect(input.areaSqm, 96.5);
    expect(input.maxGuests, 2);
    expect(input.bedrooms, isNull);
    expect(input.status, ListingStatus.published, reason: 'new listings are published by default');
    expect(find.text('MY LISTINGS'), findsOneWidget);
    expect(find.text('Listing saved'), findsOneWidget);
  });

  testWidgets('asks before discarding unsaved changes', (tester) async {
    await pumpForm(tester);
    await tester.enterText(field('Title'), 'Draft');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('MY LISTINGS'), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('MY LISTINGS'), findsOneWidget);
  });
}
