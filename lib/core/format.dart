import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../core/api_client.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeName => Localizations.localeOf(this).toLanguageTag();
}

extension ListingTexts on AppLocalizations {
  String propertyType(PropertyType type) => switch (type) {
    PropertyType.house => propertyHouse,
    PropertyType.cottage => propertyCottage,
    PropertyType.dacha => propertyDacha,
    PropertyType.apartment => propertyApartment,
  };

  String status(ListingStatus? status) => switch (status) {
    null => statusAll,
    ListingStatus.draft => statusDraft,
    ListingStatus.published => statusPublished,
    ListingStatus.archived => statusArchived,
  };

  String period(PricePeriod period) => switch (period) {
    PricePeriod.day => perDay,
    PricePeriod.month => perMonth,
  };

  /// A user-facing message for any error thrown by the API layer.
  String error(Object error) {
    if (error is! ApiException) return errorServer;
    final message = error.message ?? '';
    return switch (error.kind) {
      ApiErrorKind.network => errorNetwork,
      ApiErrorKind.unauthorized when message.contains('email or password') => errorInvalidCredentials,
      ApiErrorKind.unauthorized => errorSessionExpired,
      ApiErrorKind.forbidden when message.contains('verify your email') => errorEmailNotVerified,
      ApiErrorKind.conflict when message.contains('already registered') => errorEmailTaken,
      ApiErrorKind.badRequest when message.contains('verification') => errorInvalidCode,
      ApiErrorKind.notFound => errorNotFound,
      ApiErrorKind.unavailable => errorMailUnavailable,
      ApiErrorKind.tooManyRequests => errorTooManyRequests,
      ApiErrorKind.server => errorServer,
      // Validation and limit messages from the server are precise enough to show as is.
      _ => message.isEmpty ? errorServer : _capitalize(message),
    };
  }

  static String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

abstract final class Formatters {
  /// 850000 minor units of RUB → "8 500 ₽".
  static String price(int minor, String currency, String locale) {
    final value = minor / 100;
    final format = NumberFormat.simpleCurrency(locale: locale, name: currency, decimalDigits: minor % 100 == 0 ? 0 : 2);
    return format.format(value);
  }

  static String number(num value, String locale) => NumberFormat.decimalPattern(locale).format(value);

  static String date(DateTime date, String locale) => DateFormat.yMMMMd(locale).format(date.toLocal());

  static String monthYear(DateTime date, String locale) => DateFormat.yMMMM(locale).format(date.toLocal());
}
