import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/chat_models.dart';

class ChatRepository {
  final ApiClient apiClient;

  static const String clientDetailsBaseUrl = 'https://chatcms.xeny.ai';
  static const String conversationBaseUrl = 'https://chatai.xeny.ai';
  static const String clientId = '1charge';

  ChatRepository({required this.apiClient});

  Future<ClientDetailsResponse> getClientDetails() async {
    // Return mock data to remove API call
    return ClientDetailsResponse(
      success: true,
      message: 'Success',
      data: ClientData(
        clientId: clientId,
        clientData: ClientInfo(
          clientName: '1Care Assistant',
          clientInfo: 'Support Assistant',
          clientWebsite: 'https://onecharge.io',
          clientEmail: 'support@onecharge.io',
          clientId: clientId,
          defaultMessage: 'Hello there! How may I help you?',
        ),
      ),
    );
  }

  Future<ConversationResponse> sendMessage({
    required String message,
    required String conversationId,
    required Map<String, dynamic> clientData,
  }) async {
    // Return mock data to remove API call
    return ConversationResponse(
      success: true,
      message: 'Success',
      data: ConversationData(
        conversationId: conversationId.isEmpty
            ? 'mock_convo_id'
            : conversationId,
        response:
            "Thank you for reaching out to 1Care Support. Our team has received your message and will get back to you shortly.",
        suggestedReplies: [
          'Contact Support Team',
          'Track my Ticket',
          'Other Issue',
        ],
      ),
    );
  }
}
