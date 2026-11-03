import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/utils/logger.dart';

class JwtHandler {
  final FlutterSecureStorage _storage;

  JwtHandler(this._storage);

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
      Log.debug('Access token saved successfully.');
    } catch (e, stackTrace) {
      Log.error('Failed to save access token', error: e, stackTrace: stackTrace);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (e, stackTrace) {
      Log.error('Failed to read access token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
      Log.debug('Refresh token saved successfully.');
    } catch (e, stackTrace) {
      Log.error('Failed to save refresh token', error: e, stackTrace: stackTrace);
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (e, stackTrace) {
      Log.error('Failed to read refresh token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      Log.info('Tokens cleared successfully.');
    } catch (e, stackTrace) {
      Log.error('Failed to clear tokens', error: e, stackTrace: stackTrace);
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
