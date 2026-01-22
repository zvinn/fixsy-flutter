import 'package:flutter/material.dart';
import '../../data/models/rating_model.dart';
import '../../data/services/rating_service.dart';

/// Rating Provider
/// Manages ratings state and operations
class RatingProvider with ChangeNotifier {
  final RatingService _ratingService = RatingService();

  List<Rating> _ratings = [];
  TechnicianRating? _technicianStats;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // Getters
  List<Rating> get ratings => _ratings;
  TechnicianRating? get technicianStats => _technicianStats;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  /// Add a new rating
  Future<bool> addRating({
    required String bookingId,
    required String technicianId,
    required String userId,
    required double rating,
    String? comment,
    String? userName,
    String? technicianName,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _ratingService.addRating(
        bookingId: bookingId,
        technicianId: technicianId,
        userId: userId,
        rating: rating,
        comment: comment,
        userName: userName,
        technicianName: technicianName,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Load technician ratings
  Future<void> loadTechnicianRatings(String technicianId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ratings = await _ratingService.getTechnicianRatings(technicianId);
      _technicianStats = await _ratingService.getTechnicianStatistics(technicianId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get rating for a specific booking
  Future<Rating?> getRatingByBooking(String bookingId) async {
    try {
      return await _ratingService.getRatingByBooking(bookingId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Check if user can rate a booking
  Future<bool> canRateBooking(String bookingId, String userId) async {
    try {
      return await _ratingService.canRateBooking(bookingId, userId);
    } catch (e) {
      return false;
    }
  }

  /// Get technician statistics
  Future<TechnicianRating?> getTechnicianStatistics(String technicianId) async {
    try {
      return await _ratingService.getTechnicianStatistics(technicianId);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _ratings = [];
    _technicianStats = null;
    _isLoading = false;
    _isSubmitting = false;
    _error = null;
    notifyListeners();
  }
}
