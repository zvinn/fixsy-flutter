import '../../models/booking_model.dart';
import 'cache_manager.dart';

/// Contract for Booking Local Cache
/// Enforces Fixsy Constitution Principle IV (Offline-First Mindset).
abstract class IBookingLocalDataSource {
  Future<void> cacheUserBookings(String userId, List<Booking> bookings);
  Future<List<Booking>> getCachedUserBookings(String userId);
  Future<void> cacheBooking(Booking booking);
  Future<Booking?> getCachedBooking(String bookingId);
}

class BookingLocalDataSourceImpl implements IBookingLocalDataSource {
  final CacheManager _cacheManager;

  BookingLocalDataSourceImpl({CacheManager? cacheManager})
      : _cacheManager = cacheManager ?? CacheManager();

  static String _userBookingsKey(String userId) => 'cached_bookings_user_$userId';
  static String _bookingKey(String bookingId) => 'cached_booking_$bookingId';

  @override
  Future<void> cacheUserBookings(String userId, List<Booking> bookings) async {
    final jsonList = bookings.map((b) => b.toJson()).toList();
    await _cacheManager.put(
      _userBookingsKey(userId),
      jsonList,
      ttl: const Duration(hours: 48),
    );
  }

  @override
  Future<List<Booking>> getCachedUserBookings(String userId) async {
    final cached = await _cacheManager.get(_userBookingsKey(userId), ignoreExpired: true);
    if (cached is List) {
      return cached
          .map((item) => Booking.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  @override
  Future<void> cacheBooking(Booking booking) async {
    await _cacheManager.put(
      _bookingKey(booking.id),
      booking.toJson(),
      ttl: const Duration(hours: 48),
    );
  }

  @override
  Future<Booking?> getCachedBooking(String bookingId) async {
    final cached = await _cacheManager.get(_bookingKey(bookingId), ignoreExpired: true);
    if (cached is Map) {
      return Booking.fromJson(Map<String, dynamic>.from(cached));
    }
    return null;
  }
}
