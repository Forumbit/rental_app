import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/api_client.dart';
import 'models.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  bool get hasSession => _api.hasTokens;
  Stream<void> get sessionExpired => _api.sessionExpired;

  Future<void> restoreSession() => _api.restoreTokens();

  Future<User> login(String email, String password) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      auth: false,
    );
    await _api.saveTokens(TokenPair.fromJson(json));
    return me();
  }

  Future<User> me() async => User.fromJson(await _api.get<Map<String, dynamic>>('/auth/me'));

  Future<void> register({required String fullName, required String email, required String password}) => _api.post<void>(
    '/auth/register',
    data: {'full_name': fullName, 'email': email, 'password': password},
    auth: false,
  );

  Future<void> verifyEmail(String email, String code) =>
      _api.post<void>('/auth/verify-email', data: {'email': email, 'code': code}, auth: false);

  Future<void> resendVerification(String email) =>
      _api.post<void>('/auth/verification/resend', data: {'email': email}, auth: false);

  /// Revokes the session on the server; local tokens are cleared regardless.
  Future<void> logout() async {
    final refresh = _api.refreshToken;
    try {
      if (refresh != null) {
        await _api.post<void>('/auth/logout', data: {'refresh_token': refresh}, auth: false);
      }
    } on ApiException {
      // Already invalid or offline: logging out locally is enough.
    } finally {
      await _api.clearTokens();
    }
  }
}

class ListingsRepository {
  ListingsRepository(this._api);

  final ApiClient _api;
  static const pageSize = 12;

  Future<ListingPage> published({int? cursor}) async => ListingPage.fromJson(
    await _api.get<Map<String, dynamic>>('/listings', query: {'limit': pageSize, 'cursor': ?cursor}),
  );

  Future<Listing> publishedById(int id) async =>
      Listing.fromJson(await _api.get<Map<String, dynamic>>('/listings/$id'));

  Future<ListingPage> mine({ListingStatus? status, int? cursor}) async => ListingPage.fromJson(
    await _api.get<Map<String, dynamic>>(
      '/me/listings',
      query: {'limit': pageSize, 'status': ?status?.name, 'cursor': ?cursor},
    ),
  );

  Future<Listing> mineById(int id) async => Listing.fromJson(await _api.get<Map<String, dynamic>>('/me/listings/$id'));

  Future<Listing> create(ListingInput input) async =>
      Listing.fromJson(await _api.post<Map<String, dynamic>>('/listings', data: input.toJson()));

  Future<Listing> update(int id, ListingInput input) async =>
      Listing.fromJson(await _api.put<Map<String, dynamic>>('/listings/$id', data: input.toJson()));

  Future<void> delete(int id) => _api.delete('/listings/$id');

  Future<ListingImage> uploadImage(
    int listingId,
    Uint8List bytes, {
    required String filename,
    void Function(double progress)? onProgress,
  }) async {
    final form = FormData.fromMap({'image': MultipartFile.fromBytes(bytes, filename: filename)});
    final json = await _api.post<Map<String, dynamic>>(
      '/listings/$listingId/images',
      data: form,
      onSendProgress: onProgress == null ? null : (sent, total) => onProgress(total > 0 ? sent / total : 0),
    );
    return ListingImage.fromJson(json);
  }

  Future<void> deleteImage(int listingId, int imageId) => _api.delete('/listings/$listingId/images/$imageId');

  Future<List<ListingImage>> reorderImages(int listingId, List<int> imageIds) async {
    final json = await _api.put<List<dynamic>>('/listings/$listingId/images/order', data: {'image_ids': imageIds});
    return [for (final image in json) ListingImage.fromJson(image as Map<String, dynamic>)];
  }
}
