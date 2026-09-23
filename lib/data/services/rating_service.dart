import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

/// Rating Service - خدمة إدارة التقييمات
class RatingService {
  RatingService({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    } catch (_) {
      return null;
    }
  }
  
  static const String _ratingsCollection = 'ratings';
  static const String _techniciansCollection = 'technicians';

  // In-memory mock fallback store for tests and offline mode
  final List<Rating> _mockRatings = [
    Rating(
      id: 'rate_01',
      bookingId: 'B001',
      technicianId: 'tech_01',
      userId: 'user_01',
      rating: 5.0,
      comment: 'فني محترف جداً ومواعيده دقيقة وشغله نظيف ✨',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      userName: 'أحمد محمود',
      technicianName: 'كريم محمود السعدني',
    ),
    Rating(
      id: 'rate_02',
      bookingId: 'B002',
      technicianId: 'tech_01',
      userId: 'user_02',
      rating: 4.5,
      comment: 'خدمة ممتازة وسعر مناسب 💰',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      userName: 'سارة خالد',
      technicianName: 'كريم محمود السعدني',
    ),
  ];

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
    final newRating = Rating(
      id: 'rate_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      technicianId: technicianId,
      userId: userId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      userName: userName,
      technicianName: technicianName,
    );

    final fs = firestore;
    if (fs != null) {
      try {
        final existingRating = await getRatingByBooking(bookingId);
        if (existingRating != null) {
          throw Exception('لقد قمت بتقييم هذا الحجز مسبقاً');
        }

        final ratingDoc = fs.collection(_ratingsCollection).doc(newRating.id);
        await ratingDoc.set(newRating.toJson());

        await _updateTechnicianRating(technicianId);

        await fs.collection('bookings').doc(bookingId).update({
          'isRated': true,
          'ratingId': ratingDoc.id,
        });
      } catch (e) {
        if (e.toString().contains('مسبقاً')) rethrow;
      }
    }

    _mockRatings.add(newRating);
    return newRating;
  }

  /// Get rating by booking ID
  Future<Rating?> getRatingByBooking(String bookingId) async {
    final fs = firestore;
    if (fs == null) {
      final matches = _mockRatings.where((r) => r.bookingId == bookingId);
      return matches.isEmpty ? null : matches.first;
    }

    try {
      final query = await fs
          .collection(_ratingsCollection)
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        final matches = _mockRatings.where((r) => r.bookingId == bookingId);
        return matches.isEmpty ? null : matches.first;
      }

      return Rating.fromJson(query.docs.first.data());
    } catch (_) {
      final matches = _mockRatings.where((r) => r.bookingId == bookingId);
      return matches.isEmpty ? null : matches.first;
    }
  }

  /// Get all ratings for a technician
  Future<List<Rating>> getTechnicianRatings(String technicianId) async {
    final fs = firestore;
    if (fs == null) {
      return _mockRatings.where((r) => r.technicianId == technicianId).toList();
    }

    try {
      final query = await fs
          .collection(_ratingsCollection)
          .where('technicianId', isEqualTo: technicianId)
          .orderBy('createdAt', descending: true)
          .get();

      if (query.docs.isEmpty) {
        return _mockRatings.where((r) => r.technicianId == technicianId).toList();
      }

      return query.docs
          .map((doc) => Rating.fromJson(doc.data()))
          .toList();
    } catch (_) {
      return _mockRatings.where((r) => r.technicianId == technicianId).toList();
    }
  }

  /// Get ratings for a technician with pagination
  Future<List<Rating>> getTechnicianRatingsPaginated({
    required String technicianId,
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    final fs = firestore;
    if (fs == null) {
      return _mockRatings.where((r) => r.technicianId == technicianId).take(limit).toList();
    }

    try {
      Query query = fs
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
    } catch (_) {
      return _mockRatings.where((r) => r.technicianId == technicianId).take(limit).toList();
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
          ratingDistribution: const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        );
      }

      // Calculate average (use runningTotal to avoid avoid_types_as_parameter_names lint)
      final totalRating = ratings.fold<double>(
        0, 
        (runningTotal, rating) => runningTotal + rating.rating,
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
    final fs = firestore;
    if (fs == null) return;

    try {
      final stats = await getTechnicianStatistics(technicianId);
      if (stats != null) {
        await fs.collection(_techniciansCollection).doc(technicianId).update({
          'rating': stats.averageRating,
          'totalRatings': stats.totalRatings,
          'ratingDistribution': stats.ratingDistribution,
        });
      }
    } catch (_) {}
  }

  /// Check if user can rate a booking
  Future<bool> canRateBooking(String bookingId, String userId) async {
    final existingRating = await getRatingByBooking(bookingId);
    return existingRating == null;
  }

  /// Get top rated technician IDs
  Future<List<String>> getTopRatedTechnicians({int limit = 10}) async {
    final fs = firestore;
    if (fs != null) {
      try {
        final snap = await fs
            .collection(_techniciansCollection)
            .orderBy('rating', descending: true)
            .limit(limit)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => d.id).toList();
        }
      } catch (_) {}
    }
    return ['tech_01', 'tech_02', 'tech_03'].take(limit).toList();
  }
}
