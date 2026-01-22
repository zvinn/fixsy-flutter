/// Booking Model
class Booking {
  final String id;
  final String userId;
  final String serviceId;
  final String technicianId;
  final String status; // pending, accepted, in_progress, completed, cancelled
  final DateTime scheduledDate;
  final String address;
  final String? notes;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields for display
  final String? userName;
  final String? serviceName;
  final String? technicianName;
  
  // Rating fields
  final bool isRated;
  final String? ratingId;

  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.technicianId,
    required this.status,
    required this.scheduledDate,
    required this.address,
    this.notes,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.serviceName,
    this.technicianName,
    this.isRated = false,
    this.ratingId,
  });

  /// Create from Firestore document
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      serviceId: json['serviceId'] as String,
      technicianId: json['technicianId'] as String,
      status: json['status'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      address: json['address'] as String,
      notes: json['notes'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userName: json['userName'] as String?,
      serviceName: json['serviceName'] as String?,
      technicianName: json['technicianName'] as String?,
      isRated: json['isRated'] as bool? ?? false,
      ratingId: json['ratingId'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'technicianId': technicianId,
      'status': status,
      'scheduledDate': scheduledDate.toIso8601String(),
      'address': address,
      'notes': notes,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userName': userName,
      'serviceName': serviceName,
      'technicianName': technicianName,
      'isRated': isRated,
      'ratingId': ratingId,
    };
  }

  /// Create a copy with modified fields
  Booking copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? technicianId,
    String? status,
    DateTime? scheduledDate,
    String? address,
    String? notes,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? serviceName,
    String? technicianName,
    bool? isRated,
    String? ratingId,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      technicianId: technicianId ?? this.technicianId,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      serviceName: serviceName ?? this.serviceName,
      technicianName: technicianName ?? this.technicianName,
      isRated: isRated ?? this.isRated,
      ratingId: ratingId ?? this.ratingId,
    );
  }

  /// Check if booking is active (not completed or cancelled)
  bool get isActive =>
      status != 'completed' && status != 'cancelled';

  /// Get status in Arabic
  String get statusArabic {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'مقبول';
      case 'in_progress':
        return 'جاري التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
