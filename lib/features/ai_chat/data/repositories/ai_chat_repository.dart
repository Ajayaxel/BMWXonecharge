import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:onecharge/features/ai_chat/data/models/ai_chat_models.dart';

/// Repository for the OneCharge AI Chat backend.
///
/// API base URL : https://onecharge-ai-production.up.railway.app
/// Send message : POST /api/chat/send/{userId}
/// Get history  : GET  /api/chat/history/{userId}
class AiChatRepository {
  static const String _baseUrl =
      'https://1charge-1chargebot.up.railway.app';

  late final Dio _dio;

  AiChatRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  /// Send a chat message.
  /// [userId]   – unique session ID (e.g. "user_123")
  /// [message]  – the text the user typed
  /// [userName] – display name used for personalised system prompt on first msg
  Future<AiChatResponse> sendMessage({
    required String userId,
    required String message,
    required String userName,
  }) async {
    final endpoint = '/api/chat/send/$userId';
    final requestBody = AiChatRequest(
      message: message,
      userName: userName,
    ).toJson();

    print('\n🚀 [AiChat] POST $endpoint');
    print('📤 [AiChat] Request body : $requestBody');

    try {
      final response = await _dio.post(endpoint, data: requestBody);

      print('✅ [AiChat] Status code  : ${response.statusCode}');
      print('📥 [AiChat] Raw response : ${response.data}');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final parsed = AiChatResponse.fromJson(data);
        print('🤖 [AiChat] Parsed reply : ${parsed.responseText}');
        return parsed;
      }
      print('❌ [AiChat] Unexpected response format: $data');
      throw Exception('Unexpected response format from AI chat API');
    } on DioException catch (e) {
      print('❌ [AiChat] DioException on sendMessage: ${e.message}');
      print('❌ [AiChat] Response data : ${e.response?.data}');
      throw _handleError(e);
    }
  }

  /// Retrieve the formatted chat history for a user session.
  Future<List<AiChatHistoryEntry>> getChatHistory({
    required String userId,
  }) async {
    final endpoint = '/api/chat/history/$userId';
    print('\n🚀 [AiChat] GET $endpoint');

    try {
      final response = await _dio.get(endpoint);

      print('✅ [AiChat] Status code  : ${response.statusCode}');
      print('📥 [AiChat] Raw response : ${response.data}');

      final data = response.data;
      if (data is List) {
        final entries = data
            .whereType<Map<String, dynamic>>()
            .map(AiChatHistoryEntry.fromJson)
            .toList();
        print('📋 [AiChat] History entries loaded: ${entries.length}');
        return entries;
      }
      // Some backends wrap the list in a data key
      if (data is Map<String, dynamic>) {
        final list = data['messages'] ?? data['history'] ?? data['data'];
        if (list is List) {
          final entries = list
              .whereType<Map<String, dynamic>>()
              .map(AiChatHistoryEntry.fromJson)
              .toList();
          print(
            '📋 [AiChat] History entries loaded (wrapped): ${entries.length}',
          );
          return entries;
        }
      }
      print('⚠️  [AiChat] No history entries found, returning empty list.');
      return [];
    } on DioException catch (e) {
      print('❌ [AiChat] DioException on getChatHistory: ${e.message}');
      print('❌ [AiChat] Response data : ${e.response?.data}');
      throw _handleError(e);
    }
  }

  /// Health-check the server.
  Future<bool> healthCheck() async {
    print('\n🚀 [AiChat] GET / (health-check)');
    try {
      final response = await _dio.get('/');
      print('✅ [AiChat] Health check status : ${response.statusCode}');
      print('📥 [AiChat] Health check body   : ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [AiChat] Health check failed  : $e');
      return false;
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      String message = 'AI Chat API Error: ${e.response?.statusCode}';
      if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      } else if (data is Map && data.containsKey('detail')) {
        message = data['detail'].toString();
      }
      print('❌ [AiChat] Error response (${e.response?.statusCode}): $message');
      return Exception(message);
    }
    print('❌ [AiChat] Connection error: ${e.message}');
    return Exception('AI Chat connection error: ${e.message}');
  }
}
