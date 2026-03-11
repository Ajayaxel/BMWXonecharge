import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:onecharge/core/storage/secure_storage_service.dart';
import 'package:onecharge/features/ai_chat/data/models/ai_chat_models.dart';
import 'package:onecharge/features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import 'package:onecharge/features/ai_chat/presentation/bloc/ai_chat_event.dart';
import 'package:onecharge/features/ai_chat/presentation/bloc/ai_chat_state.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({super.key});

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Default quick-reply chips shown before any conversation starts.
  final List<String> _quickOptions = const [
    'General',
    'Payment Related Issue',
    'Issue Not Solved',
    'Agent Related Issue',
  ];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  /// Reads the logged-in user's ID and name from secure storage,
  /// then fires [AiChatInitialised] with the real values.
  Future<void> _initChat() async {
    final storage = SecureStorageService();
    final userId = await storage.getUserId();
    final userName = await storage.getUserName();

    print('🧑 [AiChat] userId  = $userId');
    print('🧑 [AiChat] userName = $userName');

    if (!mounted) return;
    context.read<AiChatBloc>().add(
      AiChatInitialised(
        userId: userId ?? 'user_anonymous',
        userName: userName ?? 'User',
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<AiChatBloc>().add(AiChatMessageSent(message));
      _messageController.clear();
    }
  }

  void _sendQuickReply(String message) {
    context.read<AiChatBloc>().add(AiChatQuickReplySent(message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat Support',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<AiChatBloc, AiChatState>(
          listener: (context, state) {
            if (state is AiChatReady || state is AiChatAwaitingReply) {
              _scrollToBottom();
            }
            if (state is AiChatError && state.messages.isNotEmpty) {
              // Show a snackbar for inline errors so we don't lose the history.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(fontFamily: 'Lufga'),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            // ── Full-screen loading (initial session load) ────────────────
            if (state is AiChatLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            // ── Full-screen error (no messages yet) ───────────────────────
            if (state is AiChatError && state.messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lufga',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AiChatBloc>().add(
                          const AiChatInitialised(
                            userId: 'user_123',
                            userName: 'User',
                          ),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // ── Resolve messages and loading flag ─────────────────────────
            List<AiChatMessage> messages = [];
            bool isAwaitingReply = false;

            if (state is AiChatReady) {
              messages = state.messages;
            } else if (state is AiChatAwaitingReply) {
              messages = state.messages;
              isAwaitingReply = true;
            } else if (state is AiChatError) {
              messages = state.messages;
            }

            return Column(
              children: [
                // ── Message list / welcome screen ─────────────────────────
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('👋', style: TextStyle(fontSize: 50)),
                              const SizedBox(height: 20),
                              const Text(
                                "HEY, i'm 1Care Assistant.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lufga',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hello there! How may I help you?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Lufga',
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          itemCount:
                              messages.length + (isAwaitingReply ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == messages.length && isAwaitingReply) {
                              return _buildTypingIndicator();
                            }
                            return _buildMessageBubble(messages[index]);
                          },
                        ),
                ),

                // ── Quick-reply chips (only before conversation starts) ────
                if (messages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickOptions
                          .map((option) => _buildQuickOption(option))
                          .toList(),
                    ),
                  ),

                // ── Input bar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: Colors.black87),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Type here',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Lufga',
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                  enabled: state is! AiChatAwaitingReply,
                                ),
                              ),
                              GestureDetector(
                                onTap: state is AiChatAwaitingReply
                                    ? null
                                    : _sendMessage,
                                child: Icon(
                                  Icons.send,
                                  color: state is AiChatAwaitingReply
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildMessageBubble(AiChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF007AFF) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: isUser
            // ── User bubble: plain white text ──────────────────────────────
            ? Text(
                message.text,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lufga',
                  color: Colors.white,
                ),
              )
            // ── AI bubble: markdown rendered ───────────────────────────────
            : MarkdownBody(
                data: message.text,
                shrinkWrap: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lufga',
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  strong: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lufga',
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  em: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lufga',
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                  listBullet: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lufga',
                    color: Colors.black87,
                  ),
                  code: const TextStyle(
                    fontSize: 13,
                    backgroundColor: Color(0xFFE0E0E0),
                    color: Colors.black87,
                  ),
                  blockquote: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Lufga',
                    color: Colors.black54,
                  ),
                ),
              ),
      ),
    );
  }

  /// Animated "..." typing indicator shown while waiting for AI reply.
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          width: 24,
          height: 16,
          child: CupertinoActivityIndicator(radius: 8),
        ),
      ),
    );
  }

  Widget _buildQuickOption(String text) {
    return GestureDetector(
      onTap: () => _sendQuickReply(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
