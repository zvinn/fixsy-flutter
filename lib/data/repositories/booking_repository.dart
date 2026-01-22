import '../models/booking_model.dart';
import '../services/firestore_service.dart';

/// Booking Repository
/// Manages booking data operations
class BookingRepository {
  final FirestoreService _firestoreService = FirestoreService();

  static const String _collection = 'bookings';

  /// Create a new booking
  Future<String> createBooking(Booking booking) async {
    try {
      return await _firestoreService.createDocument(
        collection: _collection,
        data: booking.toJson(),
      );
    } catch (e) {
      throw Exception('خطأ في إنشاء الحجز: ${e.toString()}');
    }
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final data = await _firestoreService.getDocument(
        collection: _collection,
        docId: bookingId,
      );

      if (data != null) {
        return Booking.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب الحجز: ${e.toString()}');
    }
  }

  /// Get user bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final data = await _firestoreService.queryCollection(
        collection: _collection,
        filters: [
          {'field': 'userId', 'operator': '==', 'value': userId},
        ],
        orderBy: 'createdAt',
        descending: true,
      );

      return data.map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الحجوزات: ${e.toString()}');
    }
  }

  /// Get technician bookings
  Future<List<Booking>> getTechnicianBookings(String technicianId) async {
    try {
      final data = await _firestoreService.queryCollection(
        collection: _collection,
        filters: [
          {'field': 'technicianId', 'operator': '==', 'value': technicianId},
        ],
        orderBy: 'createdAt',
        descending: true,
      );

      return data.map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الحجوزات: ${e.toString()}');
    }
  }

  /// Get bookings by status
  Future<List<Booking>> getBookingsByStatus({
    required String userId,
    required String status,
  }) async {
    try {
      final data = await _firestoreService.queryCollection(
        collection: _collection,
        filters: [
          {'field': 'userId', 'operator': '==', 'value': userId},
          {'field': 'status', 'operator': '==', 'value': status},
        ],
        orderBy: 'createdAt',
        descending: true,
      );

      return data.map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الحجوزات: ${e.toString()}');
    }
  }

  /// Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await _firestoreService.updateDocument(
        collection: _collection,
        docId: bookingId,
        data: {
          'status': status,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('خطأ في تحديث حالة الحجز: ${e.toString()}');
    }
  }

  /// Update booking
  Future<void> updateBooking(String bookingId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _firestoreService.updateDocument(
        collection: _collection,
        docId: bookingId,
        data: updates,
      );
    } catch (e) {
      throw Exception('خطأ في تحديث الحجز: ${e.toString()}');
    }
  }

  /// Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId: bookingId, status: 'cancelled');
    } catch (e) {
      throw Exception('خطأ في إلغاء الحجز: ${e.toString()}');
    }
  }

  /// Delete booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: _collection,
        docId: bookingId,
      );
    } catch (e) {
      throw Exception('خطأ في حذف الحجز: ${e.toString()}');
    }
  }

  /// Stream user bookings
  Stream<List<Booking>> streamUserBookings(String userId) {
    return _firestoreService
        .streamCollection(
          collection: _collection,
          queryBuilder: (query) => query
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true),
        )
        .map((data) => data.map((json) => Booking.fromJson(json)).toList());
  }

  /// Stream booking by ID
  Stream<Booking?> streamBooking(String bookingId) {
    return _firestoreService
        .streamDocument(collection: _collection, docId: bookingId)
        .map((data) => data != null ? Booking.fromJson(data) : null);
  }

  /// Get active bookings (not completed or cancelled)
  Future<List<Booking>> getActiveBookings(String userId) async {
    try {
      final data = await _firestoreService.queryCollection(
        collection: _collection,
        filters: [
          {'field': 'userId', 'operator': '==', 'value': userId},
        ],
        orderBy: 'createdAt',
        descending: true,
      );

      final bookings = data.map((json) => Booking.fromJson(json)).toList();
      
      // Filter active bookings locally
      return bookings.where((booking) => booking.isActive).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الحجوزات النشطة: ${e.toString()}');
    }
  }
}
