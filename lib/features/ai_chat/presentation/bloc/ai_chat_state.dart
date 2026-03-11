import 'package:equatable/equatable.dart';
import 'package:onecharge/features/ai_chat/data/models/ai_chat_models.dart';

abstract class AiChatState extends Equatable {
  const AiChatState();

  @override
  List<Object?> get props => [];
}

/// Nothing has happened yet.
class AiChatInitial extends AiChatState {}

/// Loading initial history / session info.
class AiChatLoading extends AiChatState {}

/// Ready state — user can chat. Carries the full message list.
class AiChatReady extends AiChatState {
  final List<AiChatMessage> messages;
  final String userId;
  final String userName;

  const AiChatReady({
    required this.messages,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [messages, userId, userName];

  AiChatReady copyWith({
    List<AiChatMessage>? messages,
    String? userId,
    String? userName,
  }) {
    return AiChatReady(
      messages: messages ?? this.messages,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }
}

/// The AI is generating a response (waiting for API reply).
class AiChatAwaitingReply extends AiChatState {
  final List<AiChatMessage> messages;
  final String userId;
  final String userName;

  const AiChatAwaitingReply({
    required this.messages,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [messages, userId, userName];
}

/// An error occurred.
class AiChatError extends AiChatState {
  final String message;
  final List<AiChatMessage> messages;

  const AiChatError({required this.message, this.messages = const []});

  @override
  List<Object?> get props => [message, messages];
}
