// ── Request ──────────────────────────────────────────────────────────────────

class AiChatRequest {
  final String message;
  final String userName;

  const AiChatRequest({required this.message, required this.userName});

  Map<String, dynamic> toJson() => {'message': message, 'user_name': userName};
}

// ── Response (Send Message) ──────────────────────────────────────────────────

class AiChatResponse {
  final String? reply;
  final String? message;
  final bool success;

  const AiChatResponse({this.reply, this.message, this.success = true});

  /// The AI text to display in the bubble
  String get responseText => reply ?? message ?? '';

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      reply:
          json['content']?.toString() ?? // ← actual API key: {role, content}
          json['reply']?.toString() ??
          json['response']?.toString() ??
          json['message']?.toString(),
      message: json['message']?.toString(),
      success: json['success'] as bool? ?? true,
    );
  }
}

// ── History entry ────────────────────────────────────────────────────────────

class AiChatHistoryEntry {
  final String role; // 'user' or 'assistant'
  final String content;

  const AiChatHistoryEntry({required this.role, required this.content});

  bool get isUser => role == 'user';

  factory AiChatHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AiChatHistoryEntry(
      role: json['role']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
    );
  }
}

// ── Local message (for UI) ───────────────────────────────────────────────────

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
