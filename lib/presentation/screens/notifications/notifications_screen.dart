import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Unread, 2: Orders & Tracking, 3: Chat, 4: Promo, 5: Wallet

  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'الفني في الطريق إليك 🚗',
        message: 'الفني محمد أحمد تحرك باتجاه موقعك، الوقت التقديري للوصول هو 12 دقيقة.',
        type: NotificationType.tracking,
        date: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        actionRoute: '/live-map',
        actionLabel: 'تتبع الفني على الخريطة',
      ),
      NotificationItem(
        id: '2',
        title: 'رسالة جديدة من الفني',
        message: 'أنا متواجد بالقرب من مدخل البناية، برجاء فتح البوابة الرئيسية.',
        type: NotificationType.chat,
        date: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: false,
        actionRoute: '/chat',
        actionLabel: 'فتح المحادثة',
      ),
      NotificationItem(
        id: '3',
        title: 'تم قبول طلب الصيانة ✅',
        message: 'تم تعيين فني كهرباء لطلبك رقم #8291 وتأكيد الموعد اليوم الساعة 4:00 مساءً.',
        type: NotificationType.order,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        actionRoute: '/bookings',
        actionLabel: 'عرض الحجز',
      ),
      NotificationItem(
        id: '4',
        title: 'شحن رصيد ناجح 💳',
        message: 'تم شحن 500 ج.م في محفظتك الرقمية عبر فودافون كاش بنجاح.',
        type: NotificationType.payment,
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        actionRoute: '/wallet',
        actionLabel: 'فتح المحفظة',
      ),
      NotificationItem(
        id: '5',
        title: 'خصم خاص 20% لفترة محدودة! 🎉',
        message: 'استخدم كود FIXSY50 عند طلب أي خدمة سباكة أو تنظيف واحصل على خصم فوري.',
        type: NotificationType.promo,
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        actionRoute: '/wallet',
        actionLabel: 'تطبيق الكود في المحفظة',
      ),
      NotificationItem(
        id: '6',
        title: 'تم اكتمال الخدمة والتقييم ⭐',
        message: 'تم اكتمال طلب صيانة التكييف بنجاح. شكراً لتقييمك للفني 5 نجوم!',
        type: NotificationType.order,
        date: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        actionRoute: '/bookings',
        actionLabel: 'سجل الحجوزات',
      ),
    ];
  }

  List<NotificationItem> get _filteredNotifications {
    switch (_selectedFilterIndex) {
      case 1:
        return _notifications.where((n) => !n.isRead).toList();
      case 2:
        return _notifications
            .where((n) => n.type == NotificationType.order || n.type == NotificationType.tracking)
            .toList();
      case 3:
        return _notifications.where((n) => n.type == NotificationType.chat).toList();
      case 4:
        return _notifications.where((n) => n.type == NotificationType.promo).toList();
      case 5:
        return _notifications.where((n) => n.type == NotificationType.payment).toList();
      default:
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final unread = _unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_active_outlined, size: 22),
            const SizedBox(width: 8),
            const Text('التنبيهات والإشعارات'),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'خيارات الإشعارات',
            onSelected: (value) {
              if (value == 'read_all') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _confirmClearAll();
              } else if (value == 'simulate') {
                _simulateIncomingNotification();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.done_all, color: AppTheme.primaryColor, size: 18),
                    SizedBox(width: 8),
                    Flexible(child: Text('تحديد الكل كمقروء')),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'simulate',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notification_add_outlined, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Flexible(child: Text('إشعار تجريبي لحظي')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_sweep_outlined, color: AppTheme.errorColor, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text('مسح كل الإشعارات', style: TextStyle(color: AppTheme.errorColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          _buildFilterBar(),
          const Divider(height: 1),

          // Notification List or Empty State
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 500));
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return _buildNotificationCard(notification, index);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'الكل', 'count': _notifications.length},
      {'label': 'غير مقروءة', 'count': _unreadCount},
      {'label': 'الطلبات والتتبع', 'count': null},
      {'label': 'الرسائل', 'count': null},
      {'label': 'العروض', 'count': null},
      {'label': 'المحفظة', 'count': null},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isSelected = _selectedFilterIndex == idx;

            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item['label'] as String),
                    if (item['count'] != null && (item['count'] as int) > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${item['count']}',
                          style: TextStyle(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: isSelected,
                onSelected: (val) {
                  if (val) {
                    setState(() => _selectedFilterIndex = idx);
                  }
                },
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 68, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'لا توجد إشعارات في هذا القسم',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'ستظهر هنا إشعارات الحجوزات، تحركات الفنيين، والعروض الحصرية',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    final typeColor = _getTypeColor(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('حذف الإشعار', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      onDismissed: (_) {
        final removed = notification;
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حذف الإشعار'),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {
                setState(() {
                  _notifications.insert(index, removed);
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _showNotificationDetail(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppTheme.primaryColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead ? Colors.grey.shade200 : AppTheme.primaryColor.withValues(alpha: 0.3),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getTypeIcon(notification.type), color: typeColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Title & Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 14,
                              color: notification.isRead ? Colors.grey.shade900 : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.errorColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(notification.date),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                        ),
                        if (notification.actionLabel != null)
                          const Text(
                            'عرض التفاصيل ←',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  void _showNotificationDetail(NotificationItem notification) {
    // Mark as read
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });

    final typeColor = _getTypeColor(notification.type);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getTypeIcon(notification.type), color: typeColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _formatDate(notification.date),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                notification.message,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            if (notification.actionRoute != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, notification.actionRoute!);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    notification.actionLabel ?? 'الانتقال للخدمة',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _simulateIncomingNotification() {
    final newNotification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'تنبيه فوري: تحديث في حالة الخدمة 🔔',
      message: 'الفني يقترب من منزلك الآن، يرجى الاستعداد لاستقباله.',
      type: NotificationType.tracking,
      date: DateTime.now(),
      isRead: false,
      actionRoute: '/live-map',
      actionLabel: 'فتح الخريطة الآن',
    );

    setState(() {
      _notifications.insert(0, newNotification);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    newNotification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  Text(
                    newNotification.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'عرض',
          textColor: Colors.amber,
          onPressed: () => _showNotificationDetail(newNotification),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('مسح جميع الإشعارات', textAlign: TextAlign.center),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف كافة التنبيهات من السجل نهائياً؟',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم مسح جميع الإشعارات بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('مسح الكل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.tracking:
        return Icons.navigation;
      case NotificationType.chat:
        return Icons.chat_bubble_outline;
      case NotificationType.order:
        return Icons.home_repair_service_outlined;
      case NotificationType.promo:
        return Icons.local_offer_outlined;
      case NotificationType.payment:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.tracking:
        return Colors.blue;
      case NotificationType.chat:
        return AppTheme.successColor;
      case NotificationType.order:
        return AppTheme.primaryColor;
      case NotificationType.promo:
        return Colors.orange;
      case NotificationType.payment:
        return Colors.purple;
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
}

enum NotificationType { chat, order, promo, tracking, payment }

class NotificationItem {

  NotificationItem({
    required this.id,
    required this.message, required this.type, required this.date, required this.isRead, this.title = 'تنبيه جديد',
    this.actionRoute,
    this.actionLabel,
  });
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime date;
  final bool isRead;
  final String? actionRoute;
  final String? actionLabel;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? date,
    bool? isRead,
    String? actionRoute,
    String? actionLabel,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }
}
