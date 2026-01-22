import 'package:cloud_firestore/cloud_firestore.dart';

/// Message Type Enum
enum MessageType {
  text,
  image,
  audio,
  system,
}



/// Message Model
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      type: _parseMessageType(json['type'] as String?),
      imageUrl: json['imageUrl'] as String?,
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.name,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    String? imageUrl,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// Check if message is from current user
  bool isFromUser(String userId) => senderId == userId;
}
