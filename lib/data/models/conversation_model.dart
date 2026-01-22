import 'package:cloud_firestore/cloud_firestore.dart';

/// Conversation Model
class Conversation {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String technicianId;
  final String technicianName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount; // {userId: count, technicianId: count}
  final bool isActive;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.technicianId,
    required this.technicianName,
    this.lastMessage = '',
    required this.lastMessageTime,
    Map<String, int>? unreadCount,
    this.isActive = true,
    required this.createdAt,
  }) : unreadCount = unreadCount ?? {};

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'عميل',
      technicianId: json['technicianId'] as String,
      technicianName: json['technicianName'] as String? ?? 'فني',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] is Timestamp
          ? (json['lastMessageTime'] as Timestamp).toDate()
          : DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] != null
          ? Map<String, int>.from(json['unreadCount'] as Map)
          : {},
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Conversation copyWith({
    String? id,
    String? bookingId,
    String? userId,
    String? userName,
    String? technicianId,
    String? technicianName,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get unread count for specific user
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// Get other participant name (for current user)
  String getOtherParticipantName(String currentUserId) {
    return currentUserId == userId ? technicianName : userName;
  }

  /// Get other participant ID
  String getOtherParticipantId(String currentUserId) {
    return currentUserId == userId ? technicianId : userId;
  }
}
