import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _tokenKey = 'access_token';
  static const String _userNameKey = 'user_name';
  static const String _notificationKey = 'notification_status';

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      print('✅ [TokenStorage] Access Token saved successfully');
    } catch (e) {
      print('❌ [TokenStorage] Error saving token: $e');
      rethrow;
    }
  }

  static Future<void> saveUserName(String name) async {
    try {
      await _storage.write(key: _userNameKey, value: name);
    } catch (e) {
      print('❌ [TokenStorage] Error saving name: $e');
    }
  }

  static Future<String?> readUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveNotificationStatus(bool status) async {
    try {
      // Notification status can stay in SharedPreferences or move to SecureStorage.
      // For consistency, let's keep it here for now but use SecureStorage.
      await _storage.write(key: _notificationKey, value: status.toString());
    } catch (e) {
      print('❌ [TokenStorage] Error saving notification status: $e');
    }
  }

  static Future<bool> readNotificationStatus() async {
    try {
      final value = await _storage.read(key: _notificationKey);
      return value == null || value == 'true';
    } catch (e) {
      return true;
    }
  }

  static Future<String?> readToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token;
    } catch (e) {
      print('❌ [TokenStorage] Error reading token: $e');
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userNameKey);
      print('✅ [TokenStorage] Storage cleared successfully');
    } catch (e) {
      print('❌ [TokenStorage] Error clearing storage: $e');
      rethrow;
    }
  }
}
