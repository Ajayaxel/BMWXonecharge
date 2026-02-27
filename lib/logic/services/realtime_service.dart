import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import 'package:onecharge/core/config/app_config.dart';
import 'dart:convert';

class RealtimeService {
  ReverbClient? _client;
  Channel? _customerChannel;
  final int customerId;
  final String token;

  // Callbacks for events
  final Function(dynamic data)? onTicketOffered;
  final Function(dynamic data)? onTicketAssigned;
  final Function(dynamic data)? onTicketStatusChanged;
  final Function(dynamic data)? onDriverLocationUpdated;

  RealtimeService({
    required this.customerId,
    required this.token,
    this.onTicketOffered,
    this.onTicketAssigned,
    this.onTicketStatusChanged,
    this.onDriverLocationUpdated,
  });

  Future<void> connectAndSubscribe() async {
    try {
      print(
        '🚀 [RealtimeService] Connecting to ${AppConfig.reverbHost}:${AppConfig.reverbPort}...',
      );

      // Reset singleton so fresh config is always applied
      _client?.disconnect();
      _client = null;

      _client = ReverbClient.instance(
        host: AppConfig.reverbHost,
        port: AppConfig.reverbPort,
        appKey: AppConfig.reverbAppKey,
        useTLS: AppConfig.reverbUseTls,
        authEndpoint: AppConfig.broadcastingAuthUrl,
        authorizer: _authorizer,
      );

      print('⏳ [RealtimeService] Calling _client.connect()...');

      await _client!.connect();

      print(
        '⏳ [RealtimeService] _client.connect() completed. Waiting for Socket ID...',
      );

      // Wait for Socket ID (up to 10 seconds)
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_client?.socketId != null) break;
      }

      if (_client?.socketId == null) {
        print('❌ [RealtimeService] Failed to get Socket ID after 10s.');
        return;
      }

      print('✅ [RealtimeService] Connected! Socket ID: ${_client?.socketId}');

      final channelName = 'private-customer.$customerId.driver-location';
      _customerChannel = _client!.subscribeToPrivateChannel(channelName);

      print('✅ [RealtimeService] Subscribed to $channelName');

      _customerChannel!
        ..bind('ticket.offered', (eventName, data) {
          final parsedData = _parseData(data);
          print('🎫 [RealtimeService] Event: $eventName, Data: $parsedData');
          if (onTicketOffered != null) onTicketOffered!(parsedData);
        })
        ..bind('ticket.assigned', (eventName, data) {
          final parsedData = _parseData(data);
          print('🚗 [RealtimeService] Event: $eventName, Data: $parsedData');
          if (onTicketAssigned != null) onTicketAssigned!(parsedData);
        })
        ..bind('ticket.completed', (eventName, data) {
          final parsedData = _parseData(data);
          print('🏁 [RealtimeService] Event: $eventName, Data: $parsedData');
          // Add callback if needed, but for now just print
        })
        ..bind('ticket.status_changed', (eventName, data) {
          final parsedData = _parseData(data);
          print('⚖️ [RealtimeService] Event: $eventName, Data: $parsedData');
          if (onTicketStatusChanged != null) onTicketStatusChanged!(parsedData);
        })
        ..bind('ticket.cancelled', (eventName, data) {
          final parsedData = _parseData(data);
          print('❌ [RealtimeService] Event: $eventName, Data: $parsedData');
        })
        ..bind('driver.location.updated', (eventName, data) {
          final parsedData = _parseData(data);
          print('📍 [RealtimeService] Event: $eventName, Data: $parsedData');
          if (onDriverLocationUpdated != null)
            onDriverLocationUpdated!(parsedData);
        });
    } catch (e) {
      print('❌ [RealtimeService] Connection/Subscription error: $e');
    }
  }

  Future<Map<String, String>> _authorizer(
    String channelName,
    String socketId,
  ) async {
    print(
      '🔐 [RealtimeService] Authorizing channel: $channelName with Socket ID: $socketId',
    );
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Socket-ID': socketId, // Sometimes helpful for Reverb
    };
  }

  dynamic _parseData(dynamic data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (e) {
        print('⚠️ [RealtimeService] Failed to parse data: $e');
        return data;
      }
    }
    return data;
  }

  void disconnect() {
    print('🔌 [RealtimeService] Disconnecting...');
    _customerChannel?.unsubscribe();
    _client?.disconnect();
    _client = null;
    _customerChannel = null;
  }
}
