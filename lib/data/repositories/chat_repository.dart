import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/chat_models.dart';

class ChatRepository {
  final ApiClient apiClient;

  static const String clientDetailsBaseUrl = 'https://chatcms.xeny.ai';
  static const String conversationBaseUrl = 'https://chatai.xeny.ai';
  static const String clientId = '1charge';

  ChatRepository({required this.apiClient});

  Future<ClientDetailsResponse> getClientDetails() async {
    try {
      final response = await apiClient.getWithBaseUrl(
        '/apis/api/v1/clients/botcode/$clientId',
        clientDetailsBaseUrl,
      );
      if (response.data['success'] == true) {
        return ClientDetailsResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load client details: ${response.data['message']}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ConversationResponse> sendMessage({
    required String message,
    required String conversationId,
    required Map<String, dynamic> clientData,
  }) async {
    try {
      final request = ConversationRequest(
        clientId: clientId,
        conversationId: conversationId,
        message: message,
        clientData: clientData,
      );

      final response = await apiClient.post(
        '/chat',
        data: request.toJson(),
        baseUrl: conversationBaseUrl,
      );

      if (response.data['success'] == true) {
        return ConversationResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to send message: ${response.data['message']}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
