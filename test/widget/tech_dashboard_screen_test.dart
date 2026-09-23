import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/presentation/screens/technician/tech_dashboard_screen.dart';
import 'package:fixsy_flutter/presentation/providers/tech_dashboard_provider.dart';

void main() {
  group('TechDashboardScreen Widget Tests', () {
    testWidgets('renders technician header, stats, and jobs tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => TechDashboardProvider(),
            child: const TechDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لوحة تحكم الفني'), findsOneWidget);
      expect(find.text('م. كريم سامي'), findsOneWidget);
      expect(find.text('فني معتمد'), findsOneWidget);
      expect(find.text('جدول العمل'), findsOneWidget);
      expect(find.text('الأرباح الكلية'), findsOneWidget);
      expect(find.text('رصيد المحفظة'), findsOneWidget);
      expect(find.text('المستحق للمنصة'), findsOneWidget);
      expect(find.text('أرباح آخر 7 أيام'), findsOneWidget);
    });

    testWidgets('allows switching between active and history tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => TechDashboardProvider(),
            child: const TechDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('الطلبات النشطة'), findsOneWidget);
      expect(find.textContaining('سجل الطلبات'), findsOneWidget);

      await tester.tap(find.textContaining('سجل الطلبات'));
      await tester.pumpAndSettle();
    });

    testWidgets('opens schedule settings modal when tapping schedule button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => TechDashboardProvider(),
            child: const TechDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('جدول العمل'));
      await tester.pumpAndSettle();

      expect(find.text('إعدادات أوقات العمل وجدول الإجازات'), findsOneWidget);
      expect(find.text('حفظ الإعدادات'), findsOneWidget);
    });

    testWidgets('toggles availability switch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => TechDashboardProvider(),
            child: const TechDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
    });
  });
}
