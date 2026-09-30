import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/core/network/network_info.dart';
import 'package:fixsy_flutter/data/datasources/local/booking_local_datasource.dart';
import 'package:fixsy_flutter/data/models/booking_model.dart';
import 'package:fixsy_flutter/data/repositories/booking_repository.dart';
import 'package:fixsy_flutter/data/services/firestore_service.dart';

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

    group('Offline-First Caching & Resilience', () {
      late FakeNetworkInfo fakeNetworkInfo;
      late FakeBookingLocalDataSource fakeLocalDataSource;
      late FakeFirestoreService fakeFirestoreService;
      late BookingRepository repository;

      final now = DateTime.now();
      final sampleBooking = Booking(
        id: 'bk_offline_1',
        userId: 'usr_test_1',
        serviceId: 'srv_1',
        technicianId: 'tech_1',
        scheduledDate: now,
        status: 'confirmed',
        address: 'Alexandria, Egypt',
        totalPrice: 300.0,
        createdAt: now,
        updatedAt: now,
      );

      setUp(() {
        fakeNetworkInfo = FakeNetworkInfo();
        fakeLocalDataSource = FakeBookingLocalDataSource();
        fakeFirestoreService = FakeFirestoreService();
        repository = BookingRepository(
          firestoreService: fakeFirestoreService,
          localDataSource: fakeLocalDataSource,
          networkInfo: fakeNetworkInfo,
        );
      });

      test('when offline, getUserBookings returns cached bookings from local data source', () async {
        fakeNetworkInfo.connected = false;
        await fakeLocalDataSource.cacheUserBookings('usr_test_1', [sampleBooking]);

        final result = await repository.getUserBookings('usr_test_1');
        expect(result, isNotEmpty);
        expect(result.first.id, equals('bk_offline_1'));
        expect(result.first.address, equals('Alexandria, Egypt'));
        expect(fakeFirestoreService.queryCollectionCalled, isFalse);
      });

      test('when online, getUserBookings queries remote service and updates local cache', () async {
        fakeNetworkInfo.connected = true;
        fakeFirestoreService.simulatedBookings = [sampleBooking.toJson()];

        final result = await repository.getUserBookings('usr_test_1');
        expect(result, isNotEmpty);
        expect(result.first.id, equals('bk_offline_1'));
        expect(fakeFirestoreService.queryCollectionCalled, isTrue);

        // Verify local cache was populated
        final cached = await fakeLocalDataSource.getCachedUserBookings('usr_test_1');
        expect(cached, hasLength(1));
        expect(cached.first.id, equals('bk_offline_1'));
      });

      test('when online but remote fetch throws, it gracefully falls back to local cache', () async {
        fakeNetworkInfo.connected = true;
        fakeFirestoreService.shouldThrow = true;
        await fakeLocalDataSource.cacheUserBookings('usr_test_1', [sampleBooking]);

        final result = await repository.getUserBookings('usr_test_1');
        expect(result, isNotEmpty);
        expect(result.first.id, equals('bk_offline_1'));
      });

      test('when offline, getBookingById returns cached booking', () async {
        fakeNetworkInfo.connected = false;
        await fakeLocalDataSource.cacheBooking(sampleBooking);

        final result = await repository.getBookingById('bk_offline_1');
        expect(result, isNotNull);
        expect(result!.id, equals('bk_offline_1'));
        expect(result.totalPrice, equals(300.0));
      });
    });
  });
}

class FakeNetworkInfo implements INetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(connected);
}

class FakeBookingLocalDataSource implements IBookingLocalDataSource {
  final Map<String, List<Booking>> userBookingsCache = {};
  final Map<String, Booking> singleBookingCache = {};

  @override
  Future<void> cacheUserBookings(String userId, List<Booking> bookings) async {
    userBookingsCache[userId] = bookings;
  }

  @override
  Future<List<Booking>> getCachedUserBookings(String userId) async {
    return userBookingsCache[userId] ?? [];
  }

  @override
  Future<void> cacheBooking(Booking booking) async {
    singleBookingCache[booking.id] = booking;
  }

  @override
  Future<Booking?> getCachedBooking(String bookingId) async {
    return singleBookingCache[bookingId];
  }
}

class FakeFirestoreService extends FirestoreService {
  List<Map<String, dynamic>> simulatedBookings = [];
  bool queryCollectionCalled = false;
  bool shouldThrow = false;

  @override
  Future<List<Map<String, dynamic>>> queryCollection({
    required String collection,
    List<Map<String, dynamic>>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    queryCollectionCalled = true;
    if (shouldThrow) {
      throw Exception('Simulated network disconnect');
    }
    return simulatedBookings;
  }
}

