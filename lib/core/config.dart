/// Build-time configuration.
///
/// Override the API address with
/// `fvm flutter run --dart-define=API_BASE_URL=http://localhost:8080`.
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.your-project.site');

  /// Image URLs from the API are relative (`/images/...`).
  static String resolveUrl(String path) => path.startsWith('http') ? path : '$apiBaseUrl$path';

  /// Server limits, mirrored to validate before uploading.
  static const maxImageBytes = 5 * 1024 * 1024;
  static const maxImagesPerListing = 10;
}
