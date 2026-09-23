import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/presentation/screens/job_market/job_market_screen.dart';
import 'package:fixsy_flutter/presentation/providers/job_market_provider.dart';

void main() {
  group('JobMarketScreen Widget Tests', () {
    testWidgets('renders job market screen with tabs, filters and action button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => JobMarketProvider(),
            child: const JobMarketScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سوق العمل والمناقصات'), findsOneWidget);
      expect(find.text('الكل'), findsWidgets);
      expect(find.text('قريب منك'), findsOneWidget);
      expect(find.text('عاجل'), findsWidgets);
      expect(find.text('طلب صيانة جديد'), findsOneWidget);
      expect(find.text('سباكة'), findsWidgets);
      expect(find.text('كهرباء'), findsWidgets);
    });

    testWidgets('allows switching between tabs (قريب منك, عاجل)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => JobMarketProvider(),
            child: const JobMarketScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(Tab, 'قريب منك'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(Tab, 'عاجل'));
      await tester.pumpAndSettle();
    });

    testWidgets('taps filter chips to filter jobs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => JobMarketProvider(),
            child: const JobMarketScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final plumbingChip = find.widgetWithText(FilterChip, 'سباكة');
      if (plumbingChip.evaluate().isNotEmpty) {
        await tester.tap(plumbingChip);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('opens post job modal when clicking floating action button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => JobMarketProvider(),
            child: const JobMarketScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('طلب صيانة جديد'));
      await tester.pumpAndSettle();

      expect(find.text('طرح طلب صيانة جديد للمناقصة 🛠️'), findsOneWidget);
      expect(find.text('طرح الطلب للمناقصة الآن 🚀'), findsOneWidget);
    });
  });
}
