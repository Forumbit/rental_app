import '../core/config.dart';

enum PropertyType {
  house,
  cottage,
  dacha,
  apartment;

  static PropertyType parse(String value) => values.firstWhere((t) => t.name == value, orElse: () => house);
}

enum ListingStatus {
  draft,
  published,
  archived;

  static ListingStatus parse(String value) => values.firstWhere((s) => s.name == value, orElse: () => draft);
}

enum PricePeriod {
  day,
  month;

  static PricePeriod parse(String value) => values.firstWhere((p) => p.name == value, orElse: () => day);
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.emailVerified,
    required this.createdAt,
  });

  final int id;
  final String email;
  final String fullName;
  final bool emailVerified;
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    email: json['email'] as String,
    fullName: json['full_name'] as String,
    emailVerified: json['email_verified'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
  }
}

class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      TokenPair(accessToken: json['access_token'] as String, refreshToken: json['refresh_token'] as String);
}

class ListingImage {
  const ListingImage({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    required this.position,
  });

  final int id;
  final String url;
  final int width;
  final int height;
  final int position;

  /// Absolute URL ready for Image.network.
  String get fullUrl => AppConfig.resolveUrl(url);

  double get aspectRatio => height == 0 ? 4 / 3 : width / height;

  factory ListingImage.fromJson(Map<String, dynamic> json) => ListingImage(
    id: json['id'] as int,
    url: json['url'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
    position: json['position'] as int,
  );
}

/// Writable listing fields, the body of POST/PUT /listings.
class ListingInput {
  const ListingInput({
    required this.title,
    required this.description,
    required this.propertyType,
    required this.priceMinor,
    this.currency = 'RUB',
    this.pricePeriod = PricePeriod.day,
    this.country = 'Россия',
    this.region,
    required this.city,
    this.address,
    this.areaSqm,
    this.bedrooms,
    this.bathrooms,
    this.maxGuests,
    this.status = ListingStatus.draft,
  });

  final String title;
  final String description;
  final PropertyType propertyType;
  final int priceMinor;
  final String currency;
  final PricePeriod pricePeriod;
  final String country;
  final String? region;
  final String city;
  final String? address;
  final double? areaSqm;
  final int? bedrooms;
  final int? bathrooms;
  final int? maxGuests;
  final ListingStatus status;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'property_type': propertyType.name,
    'price_minor': priceMinor,
    'currency': currency,
    'price_period': pricePeriod.name,
    'country': country,
    'region': region,
    'city': city,
    'address': address,
    'area_sqm': areaSqm,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'max_guests': maxGuests,
    'status': status.name,
  };

  ListingInput copyWith({ListingStatus? status}) => ListingInput(
    title: title,
    description: description,
    propertyType: propertyType,
    priceMinor: priceMinor,
    currency: currency,
    pricePeriod: pricePeriod,
    country: country,
    region: region,
    city: city,
    address: address,
    areaSqm: areaSqm,
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    maxGuests: maxGuests,
    status: status ?? this.status,
  );
}

class Listing {
  const Listing({
    required this.id,
    required this.ownerId,
    required this.input,
    required this.images,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int ownerId;
  final ListingInput input;
  final List<ListingImage> images;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get title => input.title;
  ListingStatus get status => input.status;
  ListingImage? get cover => images.isEmpty ? null : images.first;

  /// "Истра, Московская область"
  String get location => [input.city, if (input.region?.isNotEmpty ?? false) input.region!].join(', ');

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
    id: json['id'] as int,
    ownerId: json['owner_id'] as int,
    input: ListingInput(
      title: json['title'] as String,
      description: json['description'] as String,
      propertyType: PropertyType.parse(json['property_type'] as String),
      priceMinor: json['price_minor'] as int,
      currency: json['currency'] as String,
      pricePeriod: PricePeriod.parse(json['price_period'] as String),
      country: json['country'] as String,
      region: json['region'] as String?,
      city: json['city'] as String,
      address: json['address'] as String?,
      areaSqm: (json['area_sqm'] as num?)?.toDouble(),
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      maxGuests: json['max_guests'] as int?,
      status: ListingStatus.parse(json['status'] as String),
    ),
    images: [
      for (final image in json['images'] as List? ?? const []) ListingImage.fromJson(image as Map<String, dynamic>),
    ]..sort((a, b) => a.position.compareTo(b.position)),
    publishedAt: json['published_at'] == null ? null : DateTime.parse(json['published_at'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

class ListingPage {
  const ListingPage({required this.items, required this.nextCursor});

  final List<Listing> items;
  final int? nextCursor;

  factory ListingPage.fromJson(Map<String, dynamic> json) => ListingPage(
    items: [for (final item in json['items'] as List) Listing.fromJson(item as Map<String, dynamic>)],
    nextCursor: json['next_cursor'] as int?,
  );
}
