import 'package:equatable/equatable.dart';
import 'package:onecharge/models/chat_models.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ClientDetailsLoaded extends ChatState {
  final ClientData clientData;
  final String defaultMessage;

  const ClientDetailsLoaded({
    required this.clientData,
    required this.defaultMessage,
  });

  @override
  List<Object?> get props => [clientData, defaultMessage];
}

class MessageSending extends ChatState {
  final List<ChatMessage> messages;
  final ClientData clientData;
  final String conversationId;

  const MessageSending({
    required this.messages,
    required this.clientData,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [messages, clientData, conversationId];
}

class MessageSent extends ChatState {
  final List<ChatMessage> messages;
  final ClientData clientData;
  final String conversationId;
  final List<String>? suggestedReplies;

  const MessageSent({
    required this.messages,
    required this.clientData,
    required this.conversationId,
    this.suggestedReplies,
  });

  @override
  List<Object?> get props => [messages, clientData, conversationId, suggestedReplies];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
