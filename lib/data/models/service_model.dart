/// Service Model
class Service {
  final String id;
  final String name;
  final String nameAr;
  final String category;
  final String description;
  final String descriptionAr;
  final double price;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.category,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      descriptionAr: json['descriptionAr'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'category': category,
      'description': description,
      'descriptionAr': descriptionAr,
      'price': price,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Service copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? category,
    String? description,
    String? descriptionAr,
    double? price,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      category: category ?? this.category,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
