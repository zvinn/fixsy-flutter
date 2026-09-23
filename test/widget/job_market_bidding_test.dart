import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/screens/job_market/job_market_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: JobMarketScreen(),
    );
  }

  group('JobMarket Bidding & Counter-Offers Tests', () {
    testWidgets('renders job market screen with tabs, filters, and jobs', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('سوق العمل والمناقصات'), findsOneWidget);
      expect(find.text('الكل'), findsWidgets);
      expect(find.text('قريب منك'), findsOneWidget);
      expect(find.text('عاجل'), findsWidgets);
      expect(find.text('إصلاح تسريب مياه'), findsOneWidget);
      expect(find.text('تقديم عرض سعر'), findsWidgets);
    });

    testWidgets('opens submit bid modal and allows submitting custom proposal', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on first "تقديم عرض سعر" button
      final submitBidButtons = find.text('تقديم عرض سعر');
      expect(submitBidButtons, findsWidgets);
      await tester.tap(submitBidButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('تقديم عرض سعر فني'), findsOneWidget);
      expect(find.textContaining('الميزانية:'), findsOneWidget);
      expect(find.text('إرسال عرض السعر للعميل 🚀'), findsOneWidget);

      // Tap submit bid button
      await tester.tap(find.text('إرسال عرض السعر للعميل 🚀'));
      await tester.pumpAndSettle();

      expect(find.textContaining('تم إرسال عرض السعر'), findsOneWidget);
    });

    testWidgets('opens bids drawer modal and displays offers', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on "2 عروض" badge
      final bidsBadge = find.text('2 عروض');
      expect(bidsBadge, findsOneWidget);
      await tester.tap(bidsBadge);
      await tester.pumpAndSettle();

      expect(find.text('العروض الفنية المقدمة'), findsOneWidget);
      expect(find.text('م. حسام الدين'), findsOneWidget);
      expect(find.text('م. خالد مصطفى'), findsOneWidget);
      expect(find.text('قبول العرض'), findsWidgets);
      expect(find.text('عرض مضاد'), findsWidgets);
    });

    testWidgets('can accept bid directly from bids drawer', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open bids drawer
      await tester.tap(find.text('2 عروض'));
      await tester.pumpAndSettle();

      // Tap accept first offer
      final acceptButtons = find.text('قبول العرض');
      await tester.tap(acceptButtons.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('تم قبول عرض'), findsOneWidget);
    });

    testWidgets('can open counter-offer dialog and submit counter proposal', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open bids drawer
      await tester.tap(find.text('2 عروض'));
      await tester.pumpAndSettle();

      // Tap on "عرض مضاد"
      final counterButtons = find.text('عرض مضاد');
      await tester.tap(counterButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('إرسال عرض سعر مضاد'), findsOneWidget);
      expect(find.text('إرسال العرض المقابل'), findsOneWidget);

      // Confirm counter offer
      await tester.tap(find.text('إرسال العرض المقابل'));
      await tester.pumpAndSettle();

      expect(find.textContaining('تم إرسال العرض المقابل'), findsOneWidget);
    });
  });
}
