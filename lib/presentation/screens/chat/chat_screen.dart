import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat/voice_recorder_widget.dart';
import '../../../data/models/message_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTypingChanged);
    
    // Mark messages as read when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<ChatProvider>().markMessagesAsRead(
          widget.conversationId, 
          auth.currentUser!.id
        );
      }
    });
  }

  void _onTypingChanged() {
    final isTyping = _messageController.text.isNotEmpty;
    if (_isTyping != isTyping) {
      setState(() => _isTyping = isTyping);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text(context.t('loginFirst'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                widget.otherUserName.isNotEmpty ? widget.otherUserName[0] : 'U',
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online', // Can be dynamic later
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatProvider.streamMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(context.t('errorOccurred')));
                }

                final messages = snapshot.data ?? [];
                
                // Auto scroll to bottom on new messages
                // Note: Better implementation would check if already at bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // _scrollToBottom(); 
                });

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(context.t('startChat'), style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.isFromUser(currentUser.id);
                    return _MobileMessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(chatProvider, currentUser.id, currentUser.displayName ?? 'User'),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatProvider chatProvider, String userId, String userName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Image Button
            IconButton(
              icon: Icon(Icons.image_outlined, color: Colors.grey.shade600),
              onPressed: () async {
                await chatProvider.sendImageMessage(
                  conversationId: widget.conversationId,
                  senderId: userId,
                  senderName: userName,
                );
              },
            ),

            // Text Input
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: context.t('writeMessage'),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (_) {
                    if (_messageController.text.isNotEmpty) {
                      chatProvider.sendMessage(
                        conversationId: widget.conversationId,
                        senderId: userId,
                        senderName: userName,
                        content: _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send or Voice Button
            _isTyping
                ? GestureDetector(
                    onTap: () {
                      chatProvider.sendMessage(
                        conversationId: widget.conversationId,
                        senderId: userId,
                        senderName: userName,
                        content: _messageController.text,
                      );
                      _messageController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  )
                : VoiceRecorderWidget(
                    onStop: (path, duration) {
                      // TODO: Implement actual audio upload
                      // For now, we'll send a text representing the audio
                      chatProvider.sendMessage(
                        conversationId: widget.conversationId,
                        senderId: userId,
                        senderName: userName,
                        content: '[Voice Message: ${duration.inSeconds}s]',
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _MobileMessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MobileMessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryColor : Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
            ),
            child: _buildContent(context),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (message.type == MessageType.image && message.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          message.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, __) => child,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      );
    }
    
    if (message.type == MessageType.audio) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow, color: isMe ? Colors.white : Colors.black87),
          const SizedBox(width: 8),
          Text(
            'Voice Message',
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
          ),
        ],
      );
    }

    return Text(
      message.content,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 15,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
