import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fixsy_flutter/data/models/booking_model.dart';
import 'package:fixsy_flutter/presentation/providers/rating_provider.dart';
import 'package:fixsy_flutter/presentation/screens/ratings/technician_ratings_screen.dart';
import 'package:fixsy_flutter/presentation/screens/ratings/add_rating_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  group('Ratings & Map Widget Tests', () {
    testWidgets('TechnicianRatingsScreen renders ratings summary and reviews', (tester) async {
      final ratingProvider = RatingProvider();
      await ratingProvider.loadTechnicianRatings('tech_01');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: ratingProvider,
            child: const TechnicianRatingsScreen(
              technicianId: 'tech_01',
              technicianName: 'كريم محمود السعدني',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تقييمات كريم محمود السعدني'), findsOneWidget);
      expect(find.text('توزيع التقييمات'), findsOneWidget);
      expect(find.text('التقييمات'), findsOneWidget);
      expect(find.text('فني محترف جداً ومواعيده دقيقة وشغله نظيف ✨'), findsOneWidget);
    });

    testWidgets('AddRatingScreen renders multi-criteria rating categories and tags', (tester) async {
      final dummyBooking = Booking(
        id: 'B001',
        userId: 'user_01',
        serviceId: 'srv_01',
        technicianId: 'tech_01',
        status: 'completed',
        scheduledDate: DateTime.now(),
        address: 'المعادي، القاهرة',
        totalPrice: 250.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        technicianName: 'كريم محمود السعدني',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => RatingProvider(),
            child: AddRatingScreen(booking: dummyBooking),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تقييم الخدمة والفني'), findsOneWidget);
      expect(find.text('ما هو تقييمك العام للخدمة؟'), findsOneWidget);
      expect(find.text('تقييم المعايير التفصيلية'), findsOneWidget);
      expect(find.text('إرسال التقييم النهائي'), findsOneWidget);
    });
  });
}
