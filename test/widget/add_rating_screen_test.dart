import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/presentation/screens/ratings/add_rating_screen.dart';
import 'package:fixsy_flutter/data/models/booking_model.dart';
import 'package:fixsy_flutter/presentation/providers/auth_provider.dart';
import 'package:fixsy_flutter/presentation/providers/rating_provider.dart';

void main() {
  final testBooking = Booking(
    id: 'booking_123',
    userId: 'user_456',
    serviceId: 'service_plumbing',
    serviceName: 'صيانة سباكة وسخانات',
    technicianId: 'tech_789',
    technicianName: 'م. أحمد حسني',
    scheduledDate: DateTime(2026, 9, 23, 14, 0),
    status: 'completed',
    totalPrice: 250.0,
    address: 'المعادي - القاهرة',
    createdAt: DateTime(2026, 9, 23, 10, 0),
    updatedAt: DateTime(2026, 9, 23, 10, 0),
  );

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
      ],
      child: MaterialApp(
        home: AddRatingScreen(booking: testBooking),
      ),
    );
  }

  group('AddRatingScreen Multi-Criteria Tests', () {
    testWidgets('renders booking info card and overall star rating', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('صيانة سباكة وسخانات'), findsOneWidget);
      expect(find.text('الفني: م. أحمد حسني'), findsOneWidget);
      expect(find.text('ما هو تقييمك العام للخدمة؟'), findsOneWidget);
      expect(find.text('إرسال التقييم النهائي'), findsOneWidget);
    });

    testWidgets('renders multi-criteria detailed ratings', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('تقييم المعايير التفصيلية'), findsOneWidget);
      expect(find.text('⏱️ الالتزام بالموعد وسرعة الحضور'), findsOneWidget);
      expect(find.text('🛠️ جودة وإتقان العمل والتشطيب'), findsOneWidget);
      expect(find.text('🧹 النظافة وحسن التعامل والأمانة'), findsOneWidget);
      expect(find.text('💰 عدالة السعر ووضوح التكلفة'), findsOneWidget);
    });

    testWidgets('allows selecting praise tags and tip amount', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on praise tag
      final tagFinder = find.text('شغل نظيف ومرتب ✨');
      await tester.ensureVisible(tagFinder);
      await tester.tap(tagFinder);
      await tester.pumpAndSettle();

      // Tap on tip 20 ج.م
      final tipFinder = find.text('20 ج.م');
      await tester.ensureVisible(tipFinder);
      await tester.tap(tipFinder);
      await tester.pumpAndSettle();

      expect(find.text('إكرامية تقديرية للفني (اختياري)'), findsOneWidget);
      expect(find.text('هل ترغب في التعامل معه مستقبلاً؟'), findsOneWidget);
    });
  });
}
