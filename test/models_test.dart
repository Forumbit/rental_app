import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rental_app/core/format.dart';
import 'package:rental_app/data/models.dart';

Map<String, dynamic> listingJson({List<Map<String, dynamic>> images = const []}) => {
  'id': 7,
  'owner_id': 2,
  'title': 'Дом',
  'description': 'Описание',
  'property_type': 'cottage',
  'price_minor': 850050,
  'currency': 'RUB',
  'price_period': 'month',
  'country': 'Россия',
  'region': null,
  'city': 'Истра',
  'address': null,
  'area_sqm': 96.5,
  'bedrooms': 0,
  'bathrooms': null,
  'max_guests': 6,
  'status': 'published',
  'published_at': '2026-11-26T11:38:58Z',
  'images': images,
  'created_at': '2026-11-26T11:38:58Z',
  'updated_at': '2026-11-26T11:38:58Z',
};

Map<String, dynamic> imageJson(int id, int position) => {
  'id': id,
  'url': '/images/$id.jpg',
  'content_type': 'image/jpeg',
  'size_bytes': 1,
  'width': 1920,
  'height': 1280,
  'position': position,
  'created_at': '2026-11-26T11:38:58Z',
};

void main() {
  setUpAll(() => initializeDateFormatting());

  test('parses a listing and orders images by position', () {
    final listing = Listing.fromJson(listingJson(images: [imageJson(3, 2), imageJson(1, 0), imageJson(2, 1)]));
    expect(listing.input.propertyType, PropertyType.cottage);
    expect(listing.input.pricePeriod, PricePeriod.month);
    expect(listing.input.bedrooms, 0);
    expect(listing.input.bathrooms, isNull);
    expect(listing.images.map((i) => i.id), [1, 2, 3]);
    expect(listing.cover!.fullUrl, endsWith('/images/1.jpg'));
    expect(listing.cover!.aspectRatio, 1.5);
    expect(listing.location, 'Истра');
  });

  test('input serializes to the API body and back', () {
    final input = Listing.fromJson(listingJson()).input;
    final json = input.toJson();
    expect(json['property_type'], 'cottage');
    expect(json['price_minor'], 850050);
    expect(json['region'], isNull);
    expect(json.containsKey('owner_id'), isFalse, reason: 'the server sets the owner');
    expect(input.copyWith(status: ListingStatus.draft).toJson()['status'], 'draft');
  });

  test('unknown enum values fall back instead of crashing', () {
    expect(PropertyType.parse('castle'), PropertyType.house);
    expect(ListingStatus.parse('blocked'), ListingStatus.draft);
  });

  test('formats prices in minor units per locale', () {
    expect(Formatters.price(850000, 'RUB', 'ru'), '8 500 ₽');
    expect(Formatters.price(850050, 'RUB', 'ru'), '8 500,50 ₽');
    expect(Formatters.price(12500, 'USD', 'en'), r'$125');
  });

  test('user initials', () {
    final user = User.fromJson({
      'id': 1,
      'email': 'a@b.c',
      'full_name': 'rental owner',
      'email_verified': true,
      'created_at': '2026-01-01T00:00:00Z',
    });
    expect(user.initials, 'RO');
  });
}
