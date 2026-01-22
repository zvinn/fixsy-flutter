/// Rating Model - نموذج التقييمات
class Rating {
  final String id;
  final String bookingId;
  final String technicianId;
  final String userId;
  final double rating; // 1-5
  final String? comment;
  final DateTime createdAt;
  
  // Additional fields for display
  final String? userName;
  final String? technicianName;

  Rating({
    required this.id,
    required this.bookingId,
    required this.technicianId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
    this.technicianName,
  });

  /// Create from Firestore document
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      technicianId: json['technicianId'] as String,
      userId: json['userId'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: json['userName'] as String?,
      technicianName: json['technicianName'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'technicianId': technicianId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'technicianName': technicianName,
    };
  }

  /// Create a copy with modified fields
  Rating copyWith({
    String? id,
    String? bookingId,
    String? technicianId,
    String? userId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    String? userName,
    String? technicianName,
  }) {
    return Rating(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      technicianId: technicianId ?? this.technicianId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      technicianName: technicianName ?? this.technicianName,
    );
  }

  /// Get rating as integer for star display
  int get ratingInt => rating.round();

  /// Check if rating is excellent (4.5+)
  bool get isExcellent => rating >= 4.5;

  /// Check if rating is good (3.5 - 4.4)
  bool get isGood => rating >= 3.5 && rating < 4.5;

  /// Check if rating is average (2.5 - 3.4)
  bool get isAverage => rating >= 2.5 && rating < 3.5;

  /// Check if rating is poor (below 2.5)
  bool get isPoor => rating < 2.5;
}

/// Technician Rating Statistics
class TechnicianRating {
  final String technicianId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // {1: 2, 2: 1, 3: 5, 4: 10, 5: 20}

  TechnicianRating({
    required this.technicianId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory TechnicianRating.fromJson(Map<String, dynamic> json) {
    return TechnicianRating(
      technicianId: json['technicianId'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'technicianId': technicianId,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': ratingDistribution,
    };
  }

  /// Get percentage for a specific star rating
  double getPercentage(int stars) {
    if (totalRatings == 0) return 0;
    final count = ratingDistribution[stars] ?? 0;
    return (count / totalRatings) * 100;
  }
}
