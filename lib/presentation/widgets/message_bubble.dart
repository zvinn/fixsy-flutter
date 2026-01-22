import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/message_model.dart';
import 'package:intl/intl.dart';

/// Message Bubble Widget
/// Displays individual chat messages
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFromCurrentUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isFromCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // System messages
    if (message.type == MessageType.system) {
      return _buildSystemMessage(context);
    }

    return Align(
      alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: isFromCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Sender name (for received messages)
            if (!isFromCurrentUser)
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Message bubble
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromCurrentUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromCurrentUser ? 16 : 4),
                  bottomRight: Radius.circular(isFromCurrentUser ? 4 : 16),
                ),
              ),
              child: message.type == MessageType.image
                  ? _buildImageMessage(context)
                  : _buildTextMessage(context),
            ),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage(BuildContext context) {
    return Text(
      message.content,
      style: TextStyle(
        color: isFromCurrentUser ? Colors.white : Colors.black87,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRounded(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onTap: () {
              // Show full screen image
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _FullScreenImage(
                    imageUrl: message.imageUrl!,
                  ),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: message.imageUrl!,
              width: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
          ),
        ),
        if (message.content != 'صورة')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message.content,
              style: TextStyle(
                color: isFromCurrentUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a', 'ar').format(time);
    } else if (difference.inDays == 1) {
      return 'أمس ${DateFormat('h:mm a', 'ar').format(time)}';
    } else {
      return DateFormat('d MMM, h:mm a', 'ar').format(time);
    }
  }
}

/// ClipRounded Widget
class ClipRounded extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRounded({
    Key? key,
    required this.child,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }
}

/// Full Screen Image Viewer
class _FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.error,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
