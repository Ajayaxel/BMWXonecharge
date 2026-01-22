import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/chat_repository.dart';
import 'package:onecharge/logic/blocs/chat/chat_event.dart';
import 'package:onecharge/logic/blocs/chat/chat_state.dart';
import 'package:onecharge/models/chat_models.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<FetchClientDetails>(_onFetchClientDetails);
    on<SendMessage>(_onSendMessage);
    on<SendQuickReply>(_onSendQuickReply);
  }

  Future<void> _onFetchClientDetails(
    FetchClientDetails event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final response = await chatRepository.getClientDetails();
      emit(ClientDetailsLoaded(
        clientData: response.data,
        defaultMessage: response.data.clientData.defaultMessage,
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final currentState = state;
      List<ChatMessage> messages;
      ClientData clientData;
      String conversationId = '';

      if (currentState is ClientDetailsLoaded) {
        clientData = currentState.clientData;
        messages = [
          ChatMessage(
            message: event.message,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        ];
      } else if (currentState is MessageSent) {
        messages = List.from(currentState.messages);
        messages.add(
          ChatMessage(
            message: event.message,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
        clientData = currentState.clientData;
        conversationId = currentState.conversationId;
      } else if (currentState is MessageSending) {
        messages = List.from(currentState.messages);
        messages.add(
          ChatMessage(
            message: event.message,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
        clientData = currentState.clientData;
        conversationId = currentState.conversationId;
      } else {
        emit(ChatError('Client details not loaded. Please wait...'));
        return;
      }

      emit(MessageSending(
        messages: messages,
        clientData: clientData,
        conversationId: conversationId,
      ));

      final response = await chatRepository.sendMessage(
        message: event.message,
        conversationId: conversationId,
        clientData: clientData.toJson(),
      );

      if (response.data != null) {
        messages.add(
          ChatMessage(
            message: response.data!.response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );

        List<String>? suggestedReplies;
        if (response.data!.suggestedReplies != null) {
          suggestedReplies = response.data!.suggestedReplies!
              .map((e) => e.toString())
              .toList();
        }

        emit(MessageSent(
          messages: messages,
          clientData: clientData,
          conversationId: response.data!.conversationId,
          suggestedReplies: suggestedReplies,
        ));
      } else {
        emit(ChatError('No response from server'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendQuickReply(
    SendQuickReply event,
    Emitter<ChatState> emit,
  ) async {
    add(SendMessage(event.message));
  }
}
