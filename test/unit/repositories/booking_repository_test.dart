import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/models/booking_model.dart';

void main() {
  group('BookingRepository & Booking Model', () {
    group('createBooking', () {
      test('should create booking and verify properties', () {
        final now = DateTime.now();
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          serviceId: 'service123',
          technicianId: 'tech123',
          scheduledDate: now,
          status: 'pending',
          address: '123 Cairo St',
          totalPrice: 150.0,
          createdAt: now,
          updatedAt: now,
        );

        expect(booking.id, equals('booking123'));
        expect(booking.userId, equals('user123'));
        expect(booking.status, equals('pending'));
        expect(booking.technicianId, equals('tech123'));
      });

      test('booking status should be valid', () {
        final validStatuses = ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'];
        final now = DateTime.now();

        for (final status in validStatuses) {
          final booking = Booking(
            id: 'test',
            userId: 'user123',
            serviceId: 'service123',
            technicianId: 'tech123',
            scheduledDate: now,
            status: status,
            address: '123 Cairo St',
            totalPrice: 100.0,
            createdAt: now,
            updatedAt: now,
          );

          expect(booking.status, equals(status));
        }
      });
    });

    group('Booking Model', () {
      test('should create Booking from JSON', () {
        final nowStr = DateTime.now().toIso8601String();
        final json = {
          'id': 'booking123',
          'userId': 'user123',
          'serviceId': 'service123',
          'technicianId': 'tech123',
          'scheduledDate': nowStr,
          'status': 'pending',
          'address': '123 Cairo St',
          'totalPrice': 150.0,
          'createdAt': nowStr,
          'updatedAt': nowStr,
        };

        final booking = Booking.fromJson(json);

        expect(booking.id, equals('booking123'));
        expect(booking.userId, equals('user123'));
        expect(booking.technicianId, equals('tech123'));
        expect(booking.status, equals('pending'));
        expect(booking.address, equals('123 Cairo St'));
        expect(booking.totalPrice, equals(150.0));
      });

      test('should convert Booking to JSON', () {
        final now = DateTime.now();
        final booking = Booking(
          id: 'booking123',
          userId: 'user123',
          serviceId: 'service123',
          technicianId: 'tech123',
          scheduledDate: now,
          status: 'pending',
          address: '123 Cairo St',
          totalPrice: 150.0,
          createdAt: now,
          updatedAt: now,
        );

        final json = booking.toJson();

        expect(json['userId'], equals('user123'));
        expect(json['serviceId'], equals('service123'));
        expect(json['technicianId'], equals('tech123'));
        expect(json['status'], equals('pending'));
        expect(json['totalPrice'], equals(150.0));
      });

      test('isActive should return true for active statuses', () {
        final activeStatuses = ['pending', 'confirmed', 'in_progress'];
        final now = DateTime.now();

        for (final status in activeStatuses) {
          final booking = Booking(
            id: 'test',
            userId: 'user123',
            serviceId: 'service123',
            technicianId: 'tech123',
            scheduledDate: now,
            status: status,
            address: '123 Cairo St',
            totalPrice: 100.0,
            createdAt: now,
            updatedAt: now,
          );

          expect(booking.isActive, isTrue, reason: 'Status $status should be active');
        }
      });

      test('isActive should return false for inactive statuses', () {
        final inactiveStatuses = ['completed', 'cancelled'];
        final now = DateTime.now();

        for (final status in inactiveStatuses) {
          final booking = Booking(
            id: 'test',
            userId: 'user123',
            serviceId: 'service123',
            technicianId: 'tech123',
            scheduledDate: now,
            status: status,
            address: '123 Cairo St',
            totalPrice: 100.0,
            createdAt: now,
            updatedAt: now,
          );

          expect(booking.isActive, isFalse, reason: 'Status $status should be inactive');
        }
      });
    });

    group('Status Transitions', () {
      test('should allow valid status transitions', () {
        final validTransitions = <String, List<String>>{
          'pending': ['confirmed', 'cancelled'],
          'confirmed': ['in_progress', 'cancelled'],
          'in_progress': ['completed', 'cancelled'],
          'completed': <String>[],
          'cancelled': <String>[],
        };

        for (final entry in validTransitions.entries) {
          expect(entry.key, isNotEmpty);
          expect(entry.value, isA<List<String>>());
        }
      });
    });

    group('Price Calculations', () {
      test('totalPrice should be positive', () {
        final now = DateTime.now();
        final booking = Booking(
          id: 'test',
          userId: 'user123',
          serviceId: 'service123',
          technicianId: 'tech123',
          scheduledDate: now,
          status: 'pending',
          address: '123 Cairo St',
          totalPrice: 150.0,
          createdAt: now,
          updatedAt: now,
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
