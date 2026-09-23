/// Saved Address Model for Fixsy Users
class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.city,
    required this.street,
    required this.createdAt,
    this.building = '',
    this.floor = '',
    this.apartment = '',
    this.notes = '',
    this.isDefault = false,
    this.latitude = 30.0444,
    this.longitude = 31.2357,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['createdAt'].toString());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return AddressModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'المنزل',
      city: json['city']?.toString() ?? 'القاهرة',
      street: json['street']?.toString() ?? '',
      building: json['building']?.toString() ?? '',
      floor: json['floor']?.toString() ?? '',
      apartment: json['apartment']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0444,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 31.2357,
      createdAt: parsedDate,
    );
  }

  final String id;
  final String label; // e.g. المنزل, العمل, شقة الوالدة
  final String city;
  final String street;
  final String building;
  final String floor;
  final String apartment;
  final String notes;
  final bool isDefault;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  String get fullAddress {
    final parts = [city, street];
    if (building.isNotEmpty) parts.add('عمارة $building');
    if (floor.isNotEmpty) parts.add('الدور $floor');
    if (apartment.isNotEmpty) parts.add('شقة $apartment');
    return parts.join('، ');
  }

  AddressModel copyWith({
    String? id,
    String? label,
    String? city,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? notes,
    bool? isDefault,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      city: city ?? this.city,
      street: street ?? this.street,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'city': city,
      'street': street,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'notes': notes,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
