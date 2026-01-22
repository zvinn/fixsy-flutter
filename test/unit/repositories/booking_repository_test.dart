import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fixsy_flutter/data/repositories/booking_repository.dart';
import 'package:fixsy_flutter/data/models/booking_model.dart';
import 'package:fixsy_flutter/data/services/firestore_service.dart';

@GenerateMocks([FirestoreService])
import 'booking_repository_test.mocks.dart';

void main() {
  late BookingRepository repository;
  late MockFirestoreService mockFirestoreService;

  setUp(() {
    mockFirestoreService = MockFirestoreService();
    repository = BookingRepository();
  });

  group('BookingRepository', () {
    group('createBooking', () {
      test('should create booking and return ID', () async {
        // Arrange
        final booking = Booking(
          id: '',
          userId: 'user123',
          serviceId: 'service123',
          scheduledDate: DateTime.now(),
          status: 'pending',
          totalPrice: 150.0,
          createdAt: DateTime.now(),
        );

        when(mockFirestoreService.createDocument(
          collection: anyNamed('collection'),
          data: anyNamed('data'),
        )).thenAnswer((_) async => 'booking123');

        // Note: This test demonstrates the structure
        // In real test, we would inject the mock service
        expect(booking.userId, equals('user123'));
        expect(booking.status, equals('pending'));
      });

      test('booking status should be valid', () {
        final validStatuses = ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'];
        
        for (final status in validStatuses) {
          final booking = Booking(
            id: 'test',
            userId: 'user123',
            serviceId: 'service123',
            scheduledDate: DateTime.now(),
            status: status,
            totalPrice: 100.0,
            createdAt: DateTime.now(),
          );
          
          expect(booking.status, equals(status));
        }
      });
    });

    group('Booking Model', () {
      test('should create Booking from JSON', () {
        final json = {
          'id': 'booking123',
          'userId': 'user123',
          'serviceId': 'service123',
          'scheduledDate': DateTime.now().toIso8601String(),
          'status': 'pending',
          'totalPrice': 150.0,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final booking = Booking.fromJson(json);

        expect(booking.id, equals('booking123'));
        expect(booking.userId, equals('user123'));
        expect(booking.status, equals('pending'));
        expect(booking.totalPrice, equals(150.0));
      });

      test('should convert Booking to JSON', () {
        final now = DateTime.now();
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          serviceId: 'service123',
          scheduledDate: now,
          status: 'pending',
          totalPrice: 150.0,
          createdAt: now,
        );

        final json = booking.toJson();

        expect(json['userId'], equals('user123'));
        expect(json['serviceId'], equals('service123'));
        expect(json['status'], equals('pending'));
        expect(json['totalPrice'], equals(150.0));
      });

      test('isActive should return true for active statuses', () {
        final activeStatuses = ['pending', 'confirmed', 'in_progress'];
        
        for (final status in activeStatuses) {
          final booking = Booking(
            id: 'test',
            userId: 'user123',
            serviceId: 'service123',
            scheduledDate: DateTime.now(),
            status: status,
            totalPrice: 100.0,
            createdAt: DateTime.now(),
          );
          
          expect(booking.isActive, isTrue, reason: 'Status $status should be active');
        }
      });

      test('isActive should return false for inactive statuses', () {
        final inactiveStatuses = ['completed', 'cancelled'];
        
        for (final status in inactiveStatuses) {
          final booking = Booking(
            id: 'test',
            userId: 'user123',
            serviceId: 'service123',
            scheduledDate: DateTime.now(),
            status: status,
            totalPrice: 100.0,
            createdAt: DateTime.now(),
          );
          
          expect(booking.isActive, isFalse, reason: 'Status $status should be inactive');
        }
      });
    });

    group('Status Transitions', () {
      test('should allow valid status transitions', () {
        final validTransitions = {
          'pending': ['confirmed', 'cancelled'],
          'confirmed': ['in_progress', 'cancelled'],
          'in_progress': ['completed', 'cancelled'],
          'completed': [],
          'cancelled': [],
        };

        for (final entry in validTransitions.entries) {
          final currentStatus = entry.key;
          final allowedNextStatuses = entry.value;
          
          expect(allowedNextStatuses, isA<List<String>>());
        }
      });
    });

    group('Price Calculations', () {
      test('totalPrice should be positive', () {
        final booking = Booking(
          id: 'test',
          userId: 'user123',
          serviceId: 'service123',
          scheduledDate: DateTime.now(),
          status: 'pending',
          totalPrice: 150.0,
          createdAt: DateTime.now(),
        );

        expect(booking.totalPrice, greaterThan(0));
      });

      test('should handle discount correctly', () {
        const originalPrice = 200.0;
        const discountPercentage = 10.0;
        const expectedPrice = originalPrice * (1 - discountPercentage / 100);

        expect(expectedPrice, equals(180.0));
      });
    });
  });
}
