import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/models.dart';
import 'config.dart';

enum ApiErrorKind {
  network,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  tooLarge,
  unsupportedMedia,
  tooManyRequests,
  unavailable,
  server,
}

/// An API failure with the server's message, when there is one.
class ApiException implements Exception {
  const ApiException(this.kind, {this.message, this.statusCode, this.retryAfter});

  final ApiErrorKind kind;
  final String? message;
  final int? statusCode;
  final Duration? retryAfter;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    if (response == null) {
      return const ApiException(ApiErrorKind.network);
    }
    final status = response.statusCode ?? 0;
    final data = response.data;
    final message = data is Map && data['error'] is String ? data['error'] as String : null;
    final retryAfter = int.tryParse(response.headers.value('retry-after') ?? '');
    final kind = switch (status) {
      400 => ApiErrorKind.badRequest,
      401 => ApiErrorKind.unauthorized,
      403 => ApiErrorKind.forbidden,
      404 => ApiErrorKind.notFound,
      409 => ApiErrorKind.conflict,
      413 => ApiErrorKind.tooLarge,
      415 => ApiErrorKind.unsupportedMedia,
      429 => ApiErrorKind.tooManyRequests,
      503 => ApiErrorKind.unavailable,
      _ => ApiErrorKind.server,
    };
    return ApiException(
      kind,
      message: message,
      statusCode: status,
      retryAfter: retryAfter == null ? null : Duration(seconds: retryAfter),
    );
  }

  @override
  String toString() => 'ApiException($kind, $statusCode, $message)';
}

/// Persists the token pair; flutter_secure_storage uses the Keychain on iOS,
/// encrypted preferences on Android and encrypted localStorage on the web.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  Future<TokenPair?> read() async {
    try {
      final access = await _storage.read(key: _accessKey);
      final refresh = await _storage.read(key: _refreshKey);
      if (access == null || refresh == null) return null;
      return TokenPair(accessToken: access, refreshToken: refresh);
    } catch (_) {
      // Corrupted storage (e.g. after a reinstall) must not lock the user out.
      await clear();
      return null;
    }
  }

  Future<void> write(TokenPair tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

/// HTTP client that attaches the access token and transparently refreshes it.
class ApiClient {
  ApiClient(this._storage, {Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 120),
            ),
          ) {
    this.dio.interceptors.add(InterceptorsWrapper(onRequest: _attachToken, onError: _refreshOnUnauthorized));
  }

  final Dio dio;
  final TokenStorage _storage;
  TokenPair? _tokens;
  Future<bool>? _refreshing;
  final _sessionExpired = StreamController<void>.broadcast();

  static const _retriedKey = 'retried_after_refresh';
  static const _skipAuthKey = 'skip_auth';

  /// Fires when the refresh token is rejected and the user must log in again.
  Stream<void> get sessionExpired => _sessionExpired.stream;

  bool get hasTokens => _tokens != null;
  String? get refreshToken => _tokens?.refreshToken;

  Future<void> restoreTokens() async => _tokens = await _storage.read();

  Future<void> saveTokens(TokenPair tokens) async {
    _tokens = tokens;
    await _storage.write(tokens);
  }

  Future<void> clearTokens() async {
    _tokens = null;
    await _storage.clear();
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) => _send(() => dio.get<T>(path, queryParameters: query));

  Future<T> post<T>(String path, {Object? data, bool auth = true, ProgressCallback? onSendProgress}) => _send(
    () => dio.post<T>(
      path,
      data: data,
      options: Options(extra: {_skipAuthKey: !auth}),
      onSendProgress: onSendProgress,
    ),
  );

  Future<T> put<T>(String path, {Object? data}) => _send(() => dio.put<T>(path, data: data));

  Future<void> delete(String path) => _send(() => dio.delete<void>(path));

  Future<T> _send<T>(Future<Response<T>> Function() request) async {
    try {
      return (await request()).data as T;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  void _attachToken(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokens?.accessToken;
    if (token != null && options.extra[_skipAuthKey] != true) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _refreshOnUnauthorized(DioException error, ErrorInterceptorHandler handler) async {
    final options = error.requestOptions;
    final canRetry =
        error.response?.statusCode == 401 &&
        options.headers.containsKey('Authorization') &&
        options.extra[_retriedKey] != true;
    if (!canRetry) {
      return handler.next(error);
    }
    if (!await _refreshTokens()) {
      return handler.next(error);
    }
    options.extra[_retriedKey] = true;
    options.headers['Authorization'] = 'Bearer ${_tokens!.accessToken}';
    try {
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Single flight: refresh tokens rotate, and reusing an old one makes the
  /// server revoke the whole session, so concurrent 401s share one refresh.
  Future<bool> _refreshTokens() {
    return _refreshing ??= () async {
      try {
        final refresh = _tokens?.refreshToken;
        if (refresh == null) return false;
        final response = await dio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refresh_token': refresh},
          options: Options(extra: {_skipAuthKey: true}),
        );
        await saveTokens(TokenPair.fromJson(response.data!));
        return true;
      } on DioException catch (error) {
        if (error.response?.statusCode == 401 || error.response?.statusCode == 400) {
          await clearTokens();
          _sessionExpired.add(null);
        }
        return false;
      } finally {
        _refreshing = null;
      }
    }();
  }
}
