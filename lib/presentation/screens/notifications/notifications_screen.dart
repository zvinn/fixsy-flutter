import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      message: 'تم قبول طلبك من الفني أحمد ✅',
      type: NotificationType.order,
      date: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      message: 'رسالة جديدة من الفني: أنا في الطريق إليك',
      type: NotificationType.chat,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      message: 'تم إكمال طلبك بنجاح! قيّم الخدمة الآن',
      type: NotificationType.order,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      message: 'عرض خاص: خصم 20% على خدمات السباكة 🔧',
      type: NotificationType.promo,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      message: 'الفني محمد قدم عرض على طلبك في سوق العمل',
      type: NotificationType.order,
      date: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_outlined),
            const SizedBox(width: 8),
            const Text('الإشعارات'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'قراءة الكل',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) => _buildNotificationCard(_notifications[index]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا توجد إشعارات', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: _getTypeColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(notification.type),
                color: _getTypeColor(notification.type),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(notification.date),
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Unread Indicator
            if (!notification.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.chat:
        return Icons.chat_bubble_outline;
      case NotificationType.order:
        return Icons.work_outline;
      case NotificationType.promo:
        return Icons.local_offer_outlined;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.chat:
        return AppTheme.successColor;
      case NotificationType.order:
        return AppTheme.primaryColor;
      case NotificationType.promo:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });

    // Navigate based on type
    if (notification.type == NotificationType.chat) {
      Navigator.pushNamed(context, '/chat');
    } else if (notification.type == NotificationType.order) {
      Navigator.pushNamed(context, '/bookings');
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
    );
  }
}

enum NotificationType { chat, order, promo }

class NotificationItem {
  final String id;
  final String message;
  final NotificationType type;
  final DateTime date;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.message,
    required this.type,
    required this.date,
    required this.isRead,
  });

  NotificationItem copyWith({
    String? id,
    String? message,
    NotificationType? type,
    DateTime? date,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}
