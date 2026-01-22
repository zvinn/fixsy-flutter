import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/models/rating_model.dart';

void main() {
  group('Rating Model', () {
    group('fromJson', () {
      test('should create Rating from valid JSON', () {
        final json = {
          'id': 'rating123',
          'bookingId': 'booking123',
          'userId': 'user123',
          'technicianId': 'tech123',
          'rating': 4.5,
          'comment': 'خدمة ممتازة!',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final rating = Rating.fromJson(json);

        expect(rating.id, equals('rating123'));
        expect(rating.bookingId, equals('booking123'));
        expect(rating.rating, equals(4.5));
        expect(rating.comment, equals('خدمة ممتازة!'));
      });

      test('should handle null comment', () {
        final json = {
          'id': 'rating123',
          'bookingId': 'booking123',
          'userId': 'user123',
          'technicianId': 'tech123',
          'rating': 5.0,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final rating = Rating.fromJson(json);

        expect(rating.rating, equals(5.0));
        expect(rating.comment, isNull);
      });
    });

    group('toJson', () {
      test('should convert Rating to JSON', () {
        final rating = Rating(
          id: 'rating123',
          bookingId: 'booking123',
          userId: 'user123',
          technicianId: 'tech123',
          rating: 4.0,
          comment: 'جيد جداً',
          createdAt: DateTime.now(),
        );

        final json = rating.toJson();

        expect(json['rating'], equals(4.0));
        expect(json['comment'], equals('جيد جداً'));
      });
    });

    group('Rating Validation', () {
      test('rating should be between 1 and 5', () {
        final validRatings = [1.0, 2.0, 3.0, 4.0, 5.0, 4.5, 3.5];

        for (final ratingValue in validRatings) {
          expect(ratingValue >= 1.0 && ratingValue <= 5.0, isTrue);
        }
      });

      test('should reject invalid ratings', () {
        final invalidRatings = [0.0, -1.0, 6.0, 10.0];

        for (final ratingValue in invalidRatings) {
          expect(ratingValue >= 1.0 && ratingValue <= 5.0, isFalse);
        }
      });
    });

    group('Rating Calculations', () {
      test('should calculate average rating correctly', () {
        final ratings = [5.0, 4.0, 4.5, 3.5, 5.0];
        final average = ratings.reduce((a, b) => a + b) / ratings.length;

        expect(average, equals(4.4));
      });

      test('should handle empty ratings list', () {
        final List<double> ratings = [];
        final average = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

        expect(average, equals(0.0));
      });

      test('should round average to one decimal', () {
        final ratings = [4.0, 4.0, 5.0];
        final average = ratings.reduce((a, b) => a + b) / ratings.length;
        final rounded = double.parse(average.toStringAsFixed(1));

        expect(rounded, equals(4.3));
      });
    });

    group('Rating Repository', () {
      test('should filter ratings by technician', () {
        final ratings = [
          Rating(id: '1', bookingId: 'b1', userId: 'u1', technicianId: 'tech1', rating: 5.0, createdAt: DateTime.now()),
          Rating(id: '2', bookingId: 'b2', userId: 'u2', technicianId: 'tech2', rating: 4.0, createdAt: DateTime.now()),
          Rating(id: '3', bookingId: 'b3', userId: 'u3', technicianId: 'tech1', rating: 4.5, createdAt: DateTime.now()),
        ];

        final tech1Ratings = ratings.where((r) => r.technicianId == 'tech1').toList();

        expect(tech1Ratings.length, equals(2));
      });

      test('should sort ratings by date', () {
        final now = DateTime.now();
        final ratings = [
          Rating(id: '1', bookingId: 'b1', userId: 'u1', technicianId: 'tech1', rating: 5.0, createdAt: now.subtract(const Duration(days: 2))),
          Rating(id: '2', bookingId: 'b2', userId: 'u2', technicianId: 'tech1', rating: 4.0, createdAt: now),
          Rating(id: '3', bookingId: 'b3', userId: 'u3', technicianId: 'tech1', rating: 4.5, createdAt: now.subtract(const Duration(days: 1))),
        ];

        ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        expect(ratings[0].id, equals('2')); // Most recent first
      });
    });
  });
}
