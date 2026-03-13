import 'package:shared_preferences/shared_preferences.dart';

class LocationStorage {
  const LocationStorage._();

  static const String _addressKey = 'selected_location_address';
  static const String _latKey = 'selected_location_lat';
  static const String _lngKey = 'selected_location_lng';
  static const String _isManualKey = 'is_location_manual';
  static const String _idKey = 'selected_location_id';

  static Future<void> saveSelectedLocation({
    required String address,
    required double lat,
    required double lng,
    bool isManual = true,
    int? id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressKey, address);
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
    await prefs.setBool(_isManualKey, isManual);
    if (id != null) {
      await prefs.setInt(_idKey, id);
    } else {
      await prefs.remove(_idKey);
    }
  }

  static Future<Map<String, dynamic>?> getSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString(_addressKey);
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);
    final isManual = prefs.getBool(_isManualKey) ?? false;
    final id = prefs.getInt(_idKey);

    if (address != null && lat != null && lng != null) {
      return {
        'address': address,
        'lat': lat,
        'lng': lng,
        'isManual': isManual,
        'id': id,
      };
    }
    return null;
  }

  static Future<void> clearSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_addressKey);
    await prefs.remove(_latKey);
    await prefs.remove(_lngKey);
    await prefs.remove(_isManualKey);
  }
}
