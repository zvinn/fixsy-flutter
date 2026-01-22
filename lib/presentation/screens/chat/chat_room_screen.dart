import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/message_bubble.dart';

/// Chat Room Screen
/// Real-time chat between user and technician
class ChatRoomScreen extends StatefulWidget {
  final Booking booking;

  const ChatRoomScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      await chatProvider.getOrCreateConversation(
        bookingId: widget.booking.id,
        userId: user.id,
        userName: user.displayName ?? 'عميل',
        technicianId: widget.booking.technicianId,
        technicianName: widget.booking.technicianName ?? 'فني',
      );

      // Mark messages as read
      chatProvider.markMessagesAsRead(widget.booking.id, user.id);
    }
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.booking.technicianName ?? 'فني'),
            Text(
              widget.booking.serviceName ?? 'خدمة',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatProvider.streamMessages(widget.booking.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطأ: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ابدأ المحادثة',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      isFromCurrentUser: message.isFromUser(user.id),
                    );
                  },
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Image button
                  IconButton(
                    onPressed: chatProvider.isSending
                        ? null
                        : () async {
                            final success = await chatProvider.sendImageMessage(
                              conversationId: widget.booking.id,
                              senderId: user.id,
                              senderName: user.displayName ?? 'عميل',
                            );

                            if (success) {
                              _scrollToBottom();
                            }
                          },
                    icon: const Icon(Icons.image),
                    color: Theme.of(context).primaryColor,
                  ),

                  // Text field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(chatProvider, user.id, user.displayName),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: chatProvider.isSending
                          ? null
                          : () => _sendMessage(chatProvider, user.id, user.displayName),
                      icon: chatProvider.isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(
    ChatProvider chatProvider,
    String userId,
    String? userName,
  ) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    final success = await chatProvider.sendMessage(
      conversationId: widget.booking.id,
      senderId: userId,
      senderName: userName ?? 'عميل',
      content: content,
    );

    if (success) {
      _scrollToBottom();
    } else if (chatProvider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(chatProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
