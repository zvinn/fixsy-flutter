/// Notification Model
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // booking_accepted, technician_arrived, service_completed, etc.
 final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get icon based on notification type
  String get icon {
    switch (type) {
      case 'booking_accepted':
        return '✅';
      case 'technician_arrived':
        return '🚗';
      case 'service_completed':
        return '🎉';
      case 'rating_request':
        return '⭐';
      case 'booking_reminder':
        return '⏰';
      case 'new_message':
        return '💬';
      default:
        return '🔔';
    }
  }

  /// Get notification title in Arabic
  static String getTypeTitle(String type) {
    switch (type) {
      case 'booking_accepted':
        return 'تم قبول الحجز';
      case 'technician_arrived':
        return 'وصل الفني';
      case 'service_completed':
        return 'اكتمال الخدمة';
      case 'rating_request':
        return 'قيّم الخدمة';
      case 'booking_reminder':
        return 'تذكير بالموعد';
      case 'new_message':
        return 'رسالة جديدة';
      default:
        return 'إشعار جديد';
    }
  }
}
