class ClientDetailsResponse {
  final bool success;
  final String message;
  final ClientData data;

  ClientDetailsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ClientDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ClientDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ClientData.fromJson(json['data'] ?? {}),
    );
  }
}

class ClientData {
  final String clientId;
  final ClientInfo clientData;

  ClientData({
    required this.clientId,
    required this.clientData,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      clientId: json['client_id'] ?? '',
      clientData: ClientInfo.fromJson(json['client_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_name': clientData.clientName,
      'client_info': clientData.clientInfo,
      'client_website': clientData.clientWebsite,
      'client_email': clientData.clientEmail,
      'client_id': clientData.clientId,
      'default_message': clientData.defaultMessage,
    };
  }
}

class ClientInfo {
  final String clientName;
  final String clientInfo;
  final String clientWebsite;
  final String clientEmail;
  final String clientId;
  final String defaultMessage;

  ClientInfo({
    required this.clientName,
    required this.clientInfo,
    required this.clientWebsite,
    required this.clientEmail,
    required this.clientId,
    required this.defaultMessage,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      clientName: json['client_name'] ?? '',
      clientInfo: json['client_info'] ?? '',
      clientWebsite: json['client_website'] ?? '',
      clientEmail: json['client_email'] ?? '',
      clientId: json['client_id'] ?? '',
      defaultMessage: json['default_message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_name': clientName,
      'client_info': clientInfo,
      'client_website': clientWebsite,
      'client_email': clientEmail,
      'client_id': clientId,
      'default_message': defaultMessage,
    };
  }
}

class ConversationRequest {
  final String clientId;
  final String conversationId;
  final String message;
  final Map<String, dynamic> clientData;

  ConversationRequest({
    required this.clientId,
    required this.conversationId,
    required this.message,
    required this.clientData,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'conversation_id': conversationId,
      'message': message,
      'client_data': clientData,
    };
  }
}

class ConversationResponse {
  final bool success;
  final String message;
  final ConversationData? data;

  ConversationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ConversationData.fromJson(json['data'])
          : null,
    );
  }
}

class ConversationData {
  final String conversationId;
  final String response;
  final List<dynamic>? suggestedReplies;

  ConversationData({
    required this.conversationId,
    required this.response,
    this.suggestedReplies,
  });

  factory ConversationData.fromJson(Map<String, dynamic> json) {
    return ConversationData(
      conversationId: json['conversation_id'] ?? '',
      response: json['response'] ?? json['message'] ?? '',
      suggestedReplies: json['suggested_replies'] as List<dynamic>?,
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
