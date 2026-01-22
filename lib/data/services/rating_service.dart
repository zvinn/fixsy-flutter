import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

/// Rating Service - خدمة إدارة التقييمات
class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _ratingsCollection = 'ratings';
  static const String _techniciansCollection = 'technicians';

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
      // Check if user already rated this booking
      final existingRating = await getRatingByBooking(bookingId);
      if (existingRating != null) {
        throw Exception('لقد قمت بتقييم هذا الحجز مسبقاً');
      }

      final ratingDoc = _firestore.collection(_ratingsCollection).doc();
      final newRating = Rating(
        id: ratingDoc.id,
        bookingId: bookingId,
        technicianId: technicianId,
        userId: userId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        userName: userName,
        technicianName: technicianName,
      );

      await ratingDoc.set(newRating.toJson());

      // Update technician rating statistics
      await _updateTechnicianRating(technicianId);

      // Update booking to mark as rated
      await _firestore.collection('bookings').doc(bookingId).update({
        'isRated': true,
        'ratingId': ratingDoc.id,
      });

      return newRating;
    } catch (e) {
      throw Exception('فشل إضافة التقييم: $e');
    }
  }

  /// Get rating by booking ID
  Future<Rating?> getRatingByBooking(String bookingId) async {
    try {
      final query = await _firestore
          .collection(_ratingsCollection)
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return Rating.fromJson(query.docs.first.data());
    } catch (e) {
      return null;
    }
  }

  /// Get all ratings for a technician
  Future<List<Rating>> getTechnicianRatings(String technicianId) async {
    try {
      final query = await _firestore
          .collection(_ratingsCollection)
          .where('technicianId', isEqualTo: technicianId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => Rating.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get ratings for a technician with pagination
  Future<List<Rating>> getTechnicianRatingsPaginated({
    required String technicianId,
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_ratingsCollection)
          .where('technicianId', isEqualTo: technicianId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => Rating.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get technician rating statistics
  Future<TechnicianRating?> getTechnicianStatistics(String technicianId) async {
    try {
      final ratings = await getTechnicianRatings(technicianId);
      
      if (ratings.isEmpty) {
        return TechnicianRating(
          technicianId: technicianId,
          averageRating: 0,
          totalRatings: 0,
          ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        );
      }

      // Calculate average
      final totalRating = ratings.fold<double>(
        0, 
        (sum, rating) => sum + rating.rating,
      );
      final average = totalRating / ratings.length;

      // Calculate distribution
      final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final rating in ratings) {
        final stars = rating.ratingInt;
        distribution[stars] = (distribution[stars] ?? 0) + 1;
      }

      return TechnicianRating(
        technicianId: technicianId,
        averageRating: average,
        totalRatings: ratings.length,
        ratingDistribution: distribution,
      );
    } catch (e) {
      return null;
    }
  }

  /// Update technician's average rating
  Future<void> _updateTechnicianRating(String technicianId) async {
    try {
      final stats = await getTechnicianStatistics(technicianId);
      if (stats == null) return;

      await _firestore.collection(_techniciansCollection).doc(technicianId).update({
        'averageRating': stats.averageRating,
        'totalRatings': stats.totalRatings,
        'ratingDistribution': stats.ratingDistribution,
      });
    } catch (e) {
      // Ignore error - technician document might not exist yet
    }
  }

  /// Delete a rating (admin only)
  Future<void> deleteRating(String ratingId) async {
    try {
      final ratingDoc = await _firestore
          .collection(_ratingsCollection)
          .doc(ratingId)
          .get();
      
      if (!ratingDoc.exists) {
        throw Exception('التقييم غير موجود');
      }

      final rating = Rating.fromJson(ratingDoc.data()!);
      
      // Delete the rating
      await _firestore.collection(_ratingsCollection).doc(ratingId).delete();

      // Update booking
      await _firestore.collection('bookings').doc(rating.bookingId).update({
        'isRated': false,
        'ratingId': null,
      });

      // Update technician statistics
      await _updateTechnicianRating(rating.technicianId);
    } catch (e) {
      throw Exception('فشل حذف التقييم: $e');
    }
  }

  /// Check if user can rate a booking
  Future<bool> canRateBooking(String bookingId, String userId) async {
    try {
      // Check if booking exists and is completed
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      
      if (!bookingDoc.exists) return false;
      
      final booking = bookingDoc.data()!;
      
      // Check if user owns the booking
      if (booking['userId'] != userId) return false;
      
      // Check if booking is completed
      if (booking['status'] != 'completed') return false;
      
      // Check if already rated
      if (booking['isRated'] == true) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get top rated technicians
  Future<List<String>> getTopRatedTechnicians({int limit = 10}) async {
    try {
      final query = await _firestore
          .collection(_techniciansCollection)
          .where('totalRatings', isGreaterThan: 0)
          .orderBy('totalRatings', descending: false)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }
}
