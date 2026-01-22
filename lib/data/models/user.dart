class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String role; // 'client', 'technician', 'admin'
  final DateTime createdAt;
  final String? phone;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.role,
    required this.createdAt,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'phone': phone,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? role,
    DateTime? createdAt,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
    );
  }
}
