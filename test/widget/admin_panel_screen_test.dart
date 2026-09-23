import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/presentation/providers/admin_provider.dart';
import 'package:fixsy_flutter/presentation/screens/admin/admin_panel_screen.dart';

void main() {
  group('AdminPanelScreen Widget Tests', () {
    Widget buildTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AdminProvider(),
          child: const AdminPanelScreen(),
        ),
      );
    }

    testWidgets('renders all tabs and appbar titles', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('لوحة التحكم والإدارة'), findsOneWidget);
      expect(find.text('نظرة عامة'), findsOneWidget);
      expect(find.text('التوثيق'), findsOneWidget);
      expect(find.text('المديونيات'), findsOneWidget);
      expect(find.text('الكوبونات'), findsOneWidget);
      expect(find.text('النزاعات'), findsOneWidget);
    });

    testWidgets('Overview tab displays key platform metrics', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('المستخدمين النشطين'), findsOneWidget);
      expect(find.text('الفنيين المعتمدين'), findsOneWidget);
      expect(find.text('إجمالي الحجوزات'), findsOneWidget);
      expect(find.text('حركة الطلبات والإيرادات الأسبوعية'), findsOneWidget);
    });

    testWidgets('Verification tab renders pending technician applications', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on التوثيق tab
      await tester.tap(find.text('التوثيق'));
      await tester.pumpAndSettle();

      expect(find.text('قبول وتوثيق'), findsWidgets);
      expect(find.text('رفض ذكي'), findsWidgets);
      expect(find.text('معلق'), findsWidgets);
    });

    testWidgets('Debtors tab renders debt banner and settle action', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on المديونيات tab
      await tester.tap(find.text('المديونيات'));
      await tester.pumpAndSettle();

      expect(find.text('إجمالي المديونيات المستحقة'), findsOneWidget);
      expect(find.text('تسوية الحساب'), findsWidgets);
    });

    testWidgets('Coupons tab renders add coupon button and coupon codes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on الكوبونات tab
      await tester.tap(find.text('الكوبونات'));
      await tester.pumpAndSettle();

      expect(find.text('إضافة كود خصم جديد'), findsOneWidget);
      expect(find.text('FIXSY20'), findsOneWidget);
      expect(find.text('خصم 20%'), findsOneWidget);
    });
  });
}
