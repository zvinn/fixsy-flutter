import '../models/rating_model.dart';
import '../services/rating_service.dart';

/// Rating Repository
/// Provides abstraction layer between UI and Rating Service
class RatingRepository {
  final RatingService _ratingService = RatingService();

  /// Add a new rating
  Future<Rating> addRating({
    required String bookingId,
    required String technicianId,
    required String userId,
    required double rating,
    String? comment,
    String? userName,
    String? technicianName,
  }) async {
    try {
      return await _ratingService.addRating(
        bookingId: bookingId,
        technicianId: technicianId,
        userId: userId,
        rating: rating,
        comment: comment,
        userName: userName,
        technicianName: technicianName,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get rating for a booking
  Future<Rating?> getRatingByBooking(String bookingId) async {
    try {
      return await _ratingService.getRatingByBooking(bookingId);
    } catch (e) {
      return null;
    }
  }

  /// Get all ratings for a technician
  Future<List<Rating>> getTechnicianRatings(String technicianId) async {
    try {
      return await _ratingService.getTechnicianRatings(technicianId);
    } catch (e) {
      return [];
    }
  }

  /// Get technician statistics
  Future<TechnicianRating?> getTechnicianStatistics(String technicianId) async {
    return await _ratingService.getTechnicianStatistics(technicianId);
  }

  /// Check if user can rate a booking
  Future<bool> canRateBooking(String bookingId, String userId) async {
    return await _ratingService.canRateBooking(bookingId, userId);
  }

  /// Get top rated technicians
  Future<List<String>> getTopRatedTechnicians({int limit = 10}) async {
    return await _ratingService.getTopRatedTechnicians(limit: limit);
  }
}
