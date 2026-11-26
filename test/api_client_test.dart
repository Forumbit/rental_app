import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rental_app/core/api_client.dart';
import 'package:rental_app/data/models.dart';

class MemoryTokenStorage extends TokenStorage {
  TokenPair? tokens;

  @override
  Future<TokenPair?> read() async => tokens;

  @override
  Future<void> write(TokenPair value) async => tokens = value;

  @override
  Future<void> clear() async => tokens = null;
}

/// Fake server: accepts only `access-N` of the latest generation, rotates
/// refresh tokens and counts refresh calls.
class FakeServer implements HttpClientAdapter {
  int generation = 1;
  int refreshCalls = 0;
  bool rejectRefresh = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    if (options.path == '/auth/refresh') {
      refreshCalls++;
      final body = options.data as Map;
      if (rejectRefresh || body['refresh_token'] != 'refresh-$generation') {
        return _json(401, {'error': 'invalid or expired token'});
      }
      generation++;
      return _json(200, {'access_token': 'access-$generation', 'refresh_token': 'refresh-$generation'});
    }
    if (options.headers['Authorization'] != 'Bearer access-$generation') {
      return _json(401, {'error': 'invalid or expired token'});
    }
    return _json(200, {'ok': options.path});
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeServer server;
  late MemoryTokenStorage storage;
  late ApiClient api;

  setUp(() async {
    server = FakeServer();
    storage = MemoryTokenStorage()..tokens = const TokenPair(accessToken: 'stale', refreshToken: 'refresh-1');
    api = ApiClient(storage, dio: Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = server);
    await api.restoreTokens();
  });

  test('concurrent 401s share a single refresh and all requests succeed', () async {
    final results = await Future.wait([for (var i = 0; i < 5; i++) api.get<Map<String, dynamic>>('/r$i')]);
    expect(results.map((r) => r['ok']), ['/r0', '/r1', '/r2', '/r3', '/r4']);
    expect(server.refreshCalls, 1, reason: 'reusing a rotated refresh token would revoke the session');
    expect(storage.tokens!.refreshToken, 'refresh-2');
  });

  test('a rejected refresh signs the user out', () async {
    server.rejectRefresh = true;
    final expired = Completer<void>();
    api.sessionExpired.listen((_) => expired.complete());
    await expectLater(
      api.get<Map<String, dynamic>>('/me'),
      throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.unauthorized)),
    );
    await expired.future.timeout(const Duration(seconds: 1));
    expect(storage.tokens, isNull);
    expect(api.hasTokens, isFalse);
  });

  test('requests without auth never trigger a refresh', () async {
    await expectLater(api.post<void>('/auth/login', data: {}, auth: false), throwsA(isA<ApiException>()));
    expect(server.refreshCalls, 0);
  });

  test('maps network failures and server messages', () {
    final network = ApiException.fromDio(DioException(requestOptions: RequestOptions()));
    expect(network.kind, ApiErrorKind.network);
    final limited = ApiException.fromDio(
      DioException(
        requestOptions: RequestOptions(),
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 429,
          data: {'error': 'wait'},
          headers: Headers.fromMap({
            'retry-after': ['42'],
          }),
        ),
      ),
    );
    expect(limited.kind, ApiErrorKind.tooManyRequests);
    expect(limited.message, 'wait');
    expect(limited.retryAfter, const Duration(seconds: 42));
  });
}
