import 'package:flutter/services.dart';
import 'package:onecharge/screen/home/home_screen.dart';

class CarPlayService {
  static const MethodChannel _channel = MethodChannel('com.onecharge.carplay');

  static void setupHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'bookService':
          final Map<dynamic, dynamic> args =
              call.arguments as Map<dynamic, dynamic>;
          final String categoryName = args['categoryName'] as String;
          HomeScreenState.activeState?.handleCarPlayBooking(categoryName);
          break;
      }
    });
  }

  static Future<void> updateUI() async {
    try {
      await _channel.invokeMethod('updateCarPlayUI');
    } on PlatformException catch (e) {
      print("Failed to update CarPlay UI: '${e.message}'.");
    }
  }

  static Future<void> showBookingSuccess({
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _channel.invokeMethod('showBookingSuccess', {
        'latitude': latitude,
        'longitude': longitude,
      });
    } on PlatformException catch (e) {
      print("Failed to show booking success: '${e.message}'.");
    }
  }
}
