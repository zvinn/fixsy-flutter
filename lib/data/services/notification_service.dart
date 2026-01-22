import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

/// Top-level function for background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // You can process the message here if needed
}

/// Notification Service
/// Handles Firebase Cloud Messaging and local notifications
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'fixsy_notifications', // id
    'Fixsy Notifications', // name
    description: 'Notifications for Fixsy app',
    importance: Importance.high,
  );

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission (iOS)
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle message taps (when app is in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }

    // Create notification channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    
    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );

    // Save to Firestore (optional)
    if (message.data['userId'] != null) {
      _saveNotificationToFirestore(message);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fixsy_notifications',
      'Fixsy Notifications',
      channelDescription: 'Notifications for Fixsy app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Handle message tap (from background/terminated)
  void _handleMessageTap(RemoteMessage message) {
    print('Message tapped: ${message.data}');
    // Navigate to appropriate screen based on notification type
    // This should be handled by the app's navigation logic
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle navigation
  }

  /// Handle token refresh
  Future<void> _handleTokenRefresh(String newToken) async {
    print('FCM Token refreshed: $newToken');
    // Update token in Firestore if user is logged in
  }

  /// Save FCM token to Firestore
  Future<void> saveFcmToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Save notification to Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final notificationData = {
        'userId': message.data['userId'],
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'type': message.data['type'] ?? 'general',
        'data': message.data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('notifications').add(notificationData);
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Get user notifications
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    try {
      final query = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Convert Timestamp to ISO string for parsing
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return AppNotification.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final query = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return query.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Stream notifications
  Stream<List<AppNotification>> streamNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return AppNotification.fromJson(data);
      }).toList();
    });
  }

  /// Send notification helper (for testing or local triggers)
  Future<void> sendTestNotification(String title, String body) async {
    await _showLocalNotification(
      title: title,
      body: body,
    );
  }
}
