import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onecharge/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';

/// Top-level function for handling background/terminated FCM messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔔 Background message received: ${message.messageId}');
  debugPrint('🔔 Title: ${message.notification?.title}');
  debugPrint('🔔 Body: ${message.notification?.body}');
  debugPrint('🔔 Data: ${message.data}');
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Store reference to send token to backend
  SecureStorageService? _storage;

  /// Android notification channel for high-importance foreground notifications
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'onecharge_notifications', // channel id
    'OneCharge Notifications', // channel name
    description: 'Notifications from OneCharge app',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize the entire push notification system
  Future<void> initialize({SecureStorageService? storage}) async {
    _storage = storage;

    // 1. Register the background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request permissions (iOS & Android 13+)
    await _requestPermission();

    // 3. Set up local notifications for foreground display
    await _setupLocalNotifications();

    // 4. Set up foreground message listener
    _setupForegroundListener();

    // 5. Set up notification tap handlers
    _setupNotificationTapHandlers();

    // 6. Get FCM token and send to backend
    await _getToken();

    // 7. iOS foreground presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  /// Set up flutter_local_notifications for foreground display
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Local notification tapped: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );

    // Create the Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Listen for foreground messages and display them as local notifications
  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Foreground message received: ${message.messageId}');
      debugPrint('🔔 Title: ${message.notification?.title}');
      debugPrint('🔔 Body: ${message.notification?.body}');
      debugPrint('🔔 Data: ${message.data}');

      _showLocalNotification(message);
    });
  }

  /// Display a foreground FCM message as a local notification
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Set up handlers for when user taps on a notification
  void _setupNotificationTapHandlers() {
    // When app is in background and user taps the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification tapped (background): ${message.messageId}');
      debugPrint('🔔 Data: ${message.data}');
      _handleNotificationNavigation(message.data);
    });

    // Check if the app was opened from a terminated state via notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint(
          '🔔 App opened from terminated state via notification: ${message.messageId}',
        );
        debugPrint('🔔 Data: ${message.data}');
        _handleNotificationNavigation(message.data);
      }
    });
  }

  /// Handle notification tap — navigate based on notification type
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'booking_success':
        debugPrint('🔔 Navigate to booking details: ${data['booking_id']}');
        // TODO: Navigate to booking details screen
        // NavigationService.navigateTo('/booking/${data['booking_id']}');
        break;
      case 'driver_status':
        debugPrint(
          '🔔 Navigate to tracking screen: ${data['booking_id']} - Status: ${data['status']}',
        );
        // TODO: Navigate to tracking screen
        // NavigationService.navigateTo('/tracking/${data['booking_id']}');
        break;
      default:
        debugPrint('🔔 Unknown notification type: $type');
    }
  }

  /// Handle local notification tap payload
  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        debugPrint('🔔 Notification tap data: $data');
        _handleNotificationNavigation(data);
      } catch (e) {
        debugPrint('🔔 Error parsing notification payload: $e');
      }
    }
  }

  /// Get the FCM token for this device
  Future<String?> _getToken() async {
    try {
      // On iOS, wait for the APNS token before requesting FCM token
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint(
            '🔔 APNS token not yet available (iOS Simulator or not registered). Skipping FCM token retrieval.',
          );
          _messaging.onTokenRefresh.listen((newToken) {
            debugPrint('🔔 FCM Token received (delayed): $newToken');
            _sendTokenToBackend(newToken);
          });
          return null;
        }
      }

      final token = await _messaging.getToken();
      debugPrint('🔔 FCM Token: $token');

      // Send token to backend
      if (token != null) {
        await _sendTokenToBackend(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔔 FCM Token refreshed: $newToken');
        _sendTokenToBackend(newToken);
      });

      return token;
    } catch (e) {
      debugPrint('🔔 Error getting FCM token: $e');
      debugPrint(
        '🔔 This is expected on iOS Simulator where APNS is not available.',
      );
      return null;
    }
  }

  /// Send FCM token to your PHP backend
  Future<void> _sendTokenToBackend(String fcmToken) async {
    try {
      if (_storage == null) return;

      final authToken = await _storage!.getAccessToken();
      if (authToken == null || authToken.isEmpty) {
        debugPrint('🔔 No auth token — will send FCM token after login');
        return;
      }

      final dio = Dio();
      final response = await dio.post(
        'https://app.onecharge.io/api/customer/fcm-token',
        data: {
          'fcm_token': fcmToken,
          'device_type': Platform.isIOS ? 'ios' : 'android',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('🔔 FCM token sent to backend: ${response.statusCode}');
    } catch (e) {
      debugPrint('🔔 Error sending FCM token to backend: $e');
    }
  }

  /// Call this after user logs in to send the FCM token
  Future<void> sendTokenAfterLogin(SecureStorageService storage) async {
    _storage = storage;
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('🔔 Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('🔔 Unsubscribed from topic: $topic');
  }
}
