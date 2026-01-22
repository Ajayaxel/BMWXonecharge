import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class FetchClientDetails extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class SendQuickReply extends ChatEvent {
  final String message;

  const SendQuickReply(this.message);

  @override
  List<Object?> get props => [message];
}
