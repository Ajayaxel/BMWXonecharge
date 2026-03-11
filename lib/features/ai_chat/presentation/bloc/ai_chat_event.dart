import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

/// Initialise the chat session. Loads history if available.
class AiChatInitialised extends AiChatEvent {
  final String userId;
  final String userName;

  const AiChatInitialised({required this.userId, required this.userName});

  @override
  List<Object?> get props => [userId, userName];
}

/// User typed a message and tapped send.
class AiChatMessageSent extends AiChatEvent {
  final String message;

  const AiChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// User tapped one of the quick-reply chips.
class AiChatQuickReplySent extends AiChatEvent {
  final String message;

  const AiChatQuickReplySent(this.message);

  @override
  List<Object?> get props => [message];
}
