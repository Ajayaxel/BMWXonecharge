import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();

  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _notificationKey = 'notification_status';

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_tokenKey, token);
      if (!success) {
        print('❌ [TokenStorage] Failed to save token to SharedPreferences');
        throw Exception('Failed to save token');
      }
      print('✅ [TokenStorage] Token saved successfully');
    } catch (e) {
      print('❌ [TokenStorage] Error saving token: $e');
      rethrow;
    }
  }

  static Future<void> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
    } catch (e) {
      print('❌ [TokenStorage] Error saving name: $e');
    }
  }

  static Future<String?> readUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveNotificationStatus(bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, status);
    } catch (e) {
      print('❌ [TokenStorage] Error saving notification status: $e');
    }
  }

  static Future<bool> readNotificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationKey) ?? true;
    } catch (e) {
      return true;
    }
  }

  static Future<String?> readToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token;
    } catch (e) {
      print('❌ [TokenStorage] Error reading token: $e');
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userNameKey);
      print('✅ [TokenStorage] Storage cleared successfully');
    } catch (e) {
      print('❌ [TokenStorage] Error clearing storage: $e');
      rethrow;
    }
  }
}
