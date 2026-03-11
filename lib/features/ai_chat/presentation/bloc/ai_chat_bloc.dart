import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/features/ai_chat/data/models/ai_chat_models.dart';
import 'package:onecharge/features/ai_chat/data/repositories/ai_chat_repository.dart';
import 'package:onecharge/features/ai_chat/presentation/bloc/ai_chat_event.dart';
import 'package:onecharge/features/ai_chat/presentation/bloc/ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final AiChatRepository aiChatRepository;

  AiChatBloc({required this.aiChatRepository}) : super(AiChatInitial()) {
    on<AiChatInitialised>(_onInitialised);
    on<AiChatMessageSent>(_onMessageSent);
    on<AiChatQuickReplySent>(_onQuickReplySent);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onInitialised(
    AiChatInitialised event,
    Emitter<AiChatState> emit,
  ) async {
    emit(AiChatLoading());
    try {
      // Try to load previous history. If it fails or is empty, start fresh.
      final history = await aiChatRepository.getChatHistory(
        userId: event.userId,
      );

      final messages = history
          .map(
            (h) => AiChatMessage(
              text: h.content,
              isUser: h.isUser,
              timestamp: DateTime.now(),
            ),
          )
          .toList();

      emit(
        AiChatReady(
          messages: messages,
          userId: event.userId,
          userName: event.userName,
        ),
      );
    } catch (_) {
      // Fail gracefully — just open with empty history.
      emit(
        AiChatReady(
          messages: const [],
          userId: event.userId,
          userName: event.userName,
        ),
      );
    }
  }

  Future<void> _onMessageSent(
    AiChatMessageSent event,
    Emitter<AiChatState> emit,
  ) async {
    final current = state;
    if (current is! AiChatReady && current is! AiChatError) return;

    final previousMessages = current is AiChatReady
        ? current.messages
        : (current as AiChatError).messages;
    final userId = current is AiChatReady ? current.userId : 'user_123';
    final userName = current is AiChatReady ? current.userName : 'User';

    // Append user message immediately so UI feels responsive.
    final updatedMessages = [
      ...previousMessages,
      AiChatMessage(
        text: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    ];

    emit(
      AiChatAwaitingReply(
        messages: updatedMessages,
        userId: userId,
        userName: userName,
      ),
    );

    try {
      final response = await aiChatRepository.sendMessage(
        userId: userId,
        message: event.message,
        userName: userName,
      );

      final finalMessages = [
        ...updatedMessages,
        AiChatMessage(
          text: response.responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];

      emit(
        AiChatReady(
          messages: finalMessages,
          userId: userId,
          userName: userName,
        ),
      );
    } catch (e) {
      emit(
        AiChatError(
          message: e.toString().replaceAll('Exception: ', ''),
          messages: updatedMessages,
        ),
      );
    }
  }

  Future<void> _onQuickReplySent(
    AiChatQuickReplySent event,
    Emitter<AiChatState> emit,
  ) async {
    add(AiChatMessageSent(event.message));
  }
}
