import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

/// Notification Provider
/// Manages notifications state
class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Save FCM token
  Future<void> saveFcmToken(String userId) async {
    try {
      final token = await _notificationService.getFcmToken();
      if (token != null) {
        await _notificationService.saveFcmToken(userId, token);
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Load user notifications
  Future<void> loadUserNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getUserNotifications(userId);
      _unreadCount = await _notificationService.getUnreadCount(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Stream notifications
  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _notificationService.streamNotifications(userId);
  }

  /// Send test notification (for debugging)
  Future<void> sendTestNotification() async {
    await _notificationService.sendTestNotification(
      'اختبار الإشعارات',
      'هذا إشعار تجريبي من Fixsy!',
    );
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
