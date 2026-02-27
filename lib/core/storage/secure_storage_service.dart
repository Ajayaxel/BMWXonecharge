import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userNameKey = 'user_name';

  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } on PlatformException catch (e) {
      _handleStorageError(e, 'saveAccessToken');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      _handleStorageError(e, 'getAccessToken');
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } on PlatformException catch (e) {
      _handleStorageError(e, 'saveRefreshToken');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      _handleStorageError(e, 'getRefreshToken');
      return null;
    }
  }

  Future<void> saveUserName(String name) async {
    try {
      await _storage.write(key: _userNameKey, value: name);
    } on PlatformException catch (e) {
      _handleStorageError(e, 'saveUserName');
    }
  }

  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      _handleStorageError(e, 'getUserName');
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } on PlatformException catch (e) {
      _handleStorageError(e, 'clearAll');
    }
  }

  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
    } on PlatformException catch (e) {
      _handleStorageError(e, 'deleteAccessToken');
    }
  }

  void _handleStorageError(dynamic e, String method) {
    print('⚠️ [SecureStorageService] Error in $method: $e');
    if (e is MissingPluginException) {
      print(
        '❌ [SecureStorageService] Native plugin implementation missing. Please REBUILD the app.',
      );
    }
  }
}
