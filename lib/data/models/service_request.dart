class ServiceRequest {
  final String id;
  final String userId;
  final String category;
  final String description;
  final String status; // 'pending', 'assigned', 'in_progress', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final String? technicianId;
  final List<String>? imageUrls;
  final double? estimatedPrice;
  final String? aiDiagnosis;

  ServiceRequest({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.scheduledFor,
    this.technicianId,
    this.imageUrls,
    this.estimatedPrice,
    this.aiDiagnosis,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'] as String)
          : null,
      technicianId: json['technicianId'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      estimatedPrice: json['estimatedPrice'] as double?,
      aiDiagnosis: json['aiDiagnosis'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'technicianId': technicianId,
      'imageUrls': imageUrls,
      'estimatedPrice': estimatedPrice,
      'aiDiagnosis': aiDiagnosis,
    };
  }
}
