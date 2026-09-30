import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixsy_flutter/data/datasources/local/cache_manager.dart';
import 'package:fixsy_flutter/data/datasources/local/booking_local_datasource.dart';
import 'package:fixsy_flutter/data/models/booking_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CacheManager cacheManager;
  late BookingLocalDataSourceImpl localDataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cacheManager = CacheManager();
    localDataSource = BookingLocalDataSourceImpl(cacheManager: cacheManager);
  });

  group('BookingLocalDataSourceImpl Unit Tests', () {
    final now = DateTime.now();
    final sampleBooking = Booking(
      id: 'b_101',
      userId: 'u_202',
      serviceId: 's_303',
      technicianId: 't_404',
      scheduledDate: now,
      status: 'confirmed',
      address: 'Cairo, Egypt',
      totalPrice: 250.0,
      createdAt: now,
      updatedAt: now,
    );

    test('getCachedUserBookings returns empty list when no cache exists', () async {
      final result = await localDataSource.getCachedUserBookings('unknown_user');
      expect(result, isEmpty);
    });

    test('cacheUserBookings persists and retrieves user bookings correctly', () async {
      await localDataSource.cacheUserBookings('u_202', [sampleBooking]);

      final cachedList = await localDataSource.getCachedUserBookings('u_202');
      expect(cachedList, hasLength(1));
      expect(cachedList.first.id, equals('b_101'));
      expect(cachedList.first.userId, equals('u_202'));
      expect(cachedList.first.status, equals('confirmed'));
      expect(cachedList.first.totalPrice, equals(250.0));
    });

    test('cacheBooking and getCachedBooking retrieves single booking correctly', () async {
      await localDataSource.cacheBooking(sampleBooking);

      final cached = await localDataSource.getCachedBooking('b_101');
      expect(cached, isNotNull);
      expect(cached!.id, equals('b_101'));
      expect(cached.address, equals('Cairo, Egypt'));
      expect(cached.technicianId, equals('t_404'));
    });

    test('getCachedBooking returns null for non-existent booking ID', () async {
      final cached = await localDataSource.getCachedBooking('non_existent_b_id');
      expect(cached, isNull);
    });
  });
}
