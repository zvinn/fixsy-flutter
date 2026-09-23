import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/screens/notifications/notifications_screen.dart';

void main() {
  group('NotificationsScreen Widget Tests', () {
    testWidgets('renders notifications screen with title and filter chips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('التنبيهات والإشعارات'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('غير مقروءة'), findsOneWidget);
      expect(find.text('الطلبات والتتبع'), findsOneWidget);
    });

    testWidgets('filters by unread notifications correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('غير مقروءة'));
      await tester.pumpAndSettle();

      // Should show unread items like the tracking card
      expect(find.text('الفني في الطريق إليك 🚗'), findsOneWidget);
    });

    testWidgets('opens notification detail bottom sheet on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first notification
      await tester.tap(find.text('الفني في الطريق إليك 🚗'));
      await tester.pumpAndSettle();

      // Detail bottom sheet should display action button
      expect(find.text('تتبع الفني على الخريطة'), findsOneWidget);
    });

    testWidgets('can mark all notifications as read via popup menu', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('تحديد الكل كمقروء'), findsOneWidget);
      await tester.tap(find.text('تحديد الكل كمقروء'));
      await tester.pumpAndSettle();

      expect(find.text('تم تحديد جميع الإشعارات كمقروءة'), findsOneWidget);
    });
  });
}
