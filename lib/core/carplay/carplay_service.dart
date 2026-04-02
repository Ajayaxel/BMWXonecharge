import 'dart:io';
import 'package:flutter/services.dart';
import 'package:onecharge/screen/home/home_screen.dart';

class CarPlayService {
  static const MethodChannel _channel = MethodChannel('com.onecharge.carplay');

  static void setupHandler() {
    if (!Platform.isIOS) return;
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
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('updateCarPlayUI');
    } on PlatformException catch (e) {
      print("Failed to update CarPlay UI: '${e.message}'.");
    } on MissingPluginException catch (e) {
      print("CarPlay plugin not found: '${e.message}'.");
    }
  }

  static Future<void> updateServices(List<dynamic> categories) async {
    if (!Platform.isIOS) return;
    try {
      final List<Map<String, String>> services = categories.map((c) {
        return {
          'name': (c.name ?? 'Unknown').toString(),
          'detail': 'Tap to book this service',
        };
      }).toList();
      
      // Use invokeMethod but wrap it to catch the specific MissingPluginException
      await _channel.invokeMethod('updateServices', {'services': services});
      print("Successfully pushed ${services.length} services to CarPlay.");
    } on PlatformException catch (e) {
      print("Platform error updating CarPlay services: ${e.message}");
    } on MissingPluginException {
      print("Native CarPlay plugin not yet synchronized. Please perform a full rebuild of the iOS app.");
    } catch (e) {
      print("Failed to update CarPlay services: $e");
    }
  }

  static Future<void> showBookingSuccess({
    double? latitude,
    double? longitude,
  }) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('showBookingSuccess', {
        'latitude': latitude,
        'longitude': longitude,
      });
    } on PlatformException catch (e) {
      print("Failed to show booking success: '${e.message}'.");
    } on MissingPluginException catch (e) {
      print("CarPlay plugin not found: '${e.message}'.");
    }
  }
}
