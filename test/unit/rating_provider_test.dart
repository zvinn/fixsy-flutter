import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/providers/rating_provider.dart';

void main() {
  group('RatingProvider Unit Tests', () {
    late RatingProvider ratingProvider;

    setUp(() {
      ratingProvider = RatingProvider();
    });

    test('loads technician ratings and statistics', () async {
      await ratingProvider.loadTechnicianRatings('tech_01');

      expect(ratingProvider.isLoading, isFalse);
      expect(ratingProvider.ratings.isNotEmpty, isTrue);
      expect(ratingProvider.technicianStats, isNotNull);
      expect(ratingProvider.technicianStats?.averageRating, greaterThan(0));
      expect(ratingProvider.technicianStats?.totalRatings, greaterThan(0));
    });

    test('adds a new rating successfully', () async {
      final success = await ratingProvider.addRating(
        bookingId: 'B_TEST_99',
        technicianId: 'tech_01',
        userId: 'user_test',
        rating: 4.8,
        comment: 'عمل رائع جداً',
        userName: 'علي محمود',
        technicianName: 'كريم محمود',
      );

      expect(success, isTrue);
      expect(ratingProvider.isSubmitting, isFalse);

      // Verify it's retrieved
      final rating = await ratingProvider.getRatingByBooking('B_TEST_99');
      expect(rating, isNotNull);
      expect(rating?.rating, equals(4.8));
    });

    test('checks if user can rate booking', () async {
      final canRateNew = await ratingProvider.canRateBooking('B_BRAND_NEW', 'user_01');
      expect(canRateNew, isTrue);

      // Already rated
      final canRateExisting = await ratingProvider.canRateBooking('B001', 'user_01');
      expect(canRateExisting, isFalse);
    });
  });
}
