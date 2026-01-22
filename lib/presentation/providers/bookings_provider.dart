import 'package:flutter/material.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

/// Bookings Provider
/// Manages bookings state and operations
class BookingsProvider with ChangeNotifier {
  final BookingRepository _bookingRepository = BookingRepository();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all';

  // Getters
  List<Booking> get bookings {
    if (_filterStatus == 'all') {
      return _bookings;
    }
    return _bookings
        .where((booking) => booking.status == _filterStatus)
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  /// Load user bookings
  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _bookingRepository.getUserBookings(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new booking
  Future<String?> createBooking(Booking booking) async {
    try {
      final bookingId = await _bookingRepository.createBooking(booking);
      await loadUserBookings(booking.userId); // Refresh list
      return bookingId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Update booking status
  Future<bool> updateBookingStatus({
    required String bookingId,
    required String userId,
    required String status,
  }) async {
    try {
      await _bookingRepository.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
      await loadUserBookings(userId); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancel booking
  Future<bool> cancelBooking({
    required String bookingId,
    required String userId,
  }) async {
    try {
      await _bookingRepository.cancelBooking(bookingId);
      await loadUserBookings(userId); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Filter bookings by status
  void filterByStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Get booking by ID
  Booking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  /// Get active bookings count
  int get activeBookingsCount {
    return _bookings.where((booking) => booking.isActive).length;
  }

  /// Get bookings by status
  List<Booking> getBookingsByStatus(String status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  /// Clear filters
  void clearFilters() {
    _filterStatus = 'all';
    notifyListeners();
  }

  /// Refresh bookings
  Future<void> refresh(String userId) async {
    await loadUserBookings(userId);
  }

  /// Stream user bookings (for real-time updates)
  Stream<List<Booking>> streamUserBookings(String userId) {
    return _bookingRepository.streamUserBookings(userId);
  }
}
