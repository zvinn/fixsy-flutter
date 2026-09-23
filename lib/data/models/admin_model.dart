/// Admin Model for Fixsy Platform Administration
class AdminTechnician {
  const AdminTechnician({
    required this.id,
    required this.name,
    required this.email,
    required this.specialty,
    this.nationalId = '',
    this.idCardImage,
    this.isVerified = false,
    this.debt = 0.0,
    this.unpaidOrdersCount = 0,
    this.rating = 5.0,
    this.experience = '3 سنوات',
    this.rejectionReason,
  });

  factory AdminTechnician.fromJson(Map<String, dynamic> json) {
    return AdminTechnician(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'فني بدون اسم',
      email: json['email'] as String? ?? '',
      specialty: json['specialty'] as String? ?? 'صيانة عامة',
      nationalId: json['nationalId'] as String? ?? '',
      idCardImage: json['idCardImage'] as String?,
      isVerified: json['isVerified'] ?? false,
      debt: (json['debt'] as num?)?.toDouble() ?? 0.0,
      unpaidOrdersCount: (json['unpaidOrdersCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      experience: json['experience'] as String? ?? '3 سنوات',
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  final String id;
  final String name;
  final String email;
  final String specialty;
  final String nationalId;
  final String? idCardImage;
  final dynamic isVerified; // bool or 'pending'
  final double debt;
  final int unpaidOrdersCount;
  final double rating;
  final String experience;
  final String? rejectionReason;

  bool get isPending => isVerified == 'pending' || isVerified == false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'specialty': specialty,
      'nationalId': nationalId,
      'idCardImage': idCardImage,
      'isVerified': isVerified,
      'debt': debt,
      'unpaidOrdersCount': unpaidOrdersCount,
      'rating': rating,
      'experience': experience,
      'rejectionReason': rejectionReason,
    };
  }

  AdminTechnician copyWith({
    String? id,
    String? name,
    String? email,
    String? specialty,
    String? nationalId,
    String? idCardImage,
    dynamic isVerified,
    double? debt,
    int? unpaidOrdersCount,
    double? rating,
    String? experience,
    String? rejectionReason,
  }) {
    return AdminTechnician(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
      nationalId: nationalId ?? this.nationalId,
      idCardImage: idCardImage ?? this.idCardImage,
      isVerified: isVerified ?? this.isVerified,
      debt: debt ?? this.debt,
      unpaidOrdersCount: unpaidOrdersCount ?? this.unpaidOrdersCount,
      rating: rating ?? this.rating,
      experience: experience ?? this.experience,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

class AdminCoupon {
  const AdminCoupon({
    required this.id,
    required this.code,
    required this.discount,
    this.isActive = true,
    this.expiryDate,
  });

  factory AdminCoupon.fromJson(Map<String, dynamic> json) {
    return AdminCoupon(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      discount: (json['discount'] as num?)?.toDouble() ?? 10.0,
      isActive: json['isActive'] as bool? ?? true,
      expiryDate: json['expiryDate'] as String?,
    );
  }

  final String id;
  final String code;
  final double discount;
  final bool isActive;
  final String? expiryDate;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
      'isActive': isActive,
      'expiryDate': expiryDate,
    };
  }

  AdminCoupon copyWith({
    String? id,
    String? code,
    double? discount,
    bool? isActive,
    String? expiryDate,
  }) {
    return AdminCoupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discount: discount ?? this.discount,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

class AdminDispute {
  const AdminDispute({
    required this.id,
    required this.reqId,
    required this.clientEmail,
    required this.techId,
    required this.reason,
    required this.date,
    this.status = 'pending',
  });

  factory AdminDispute.fromJson(Map<String, dynamic> json) {
    return AdminDispute(
      id: json['id'] as String? ?? '',
      reqId: json['reqId'] as String? ?? '',
      clientEmail: json['clientEmail'] as String? ?? '',
      techId: json['techId'] as String? ?? '',
      reason: json['reason'] as String? ?? 'شكوى غير محددة',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  final String id;
  final String reqId;
  final String clientEmail;
  final String techId;
  final String reason;
  final String date;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reqId': reqId,
      'clientEmail': clientEmail,
      'techId': techId,
      'reason': reason,
      'date': date,
      'status': status,
    };
  }
}

class AdminPlatformStats {
  const AdminPlatformStats({
    this.totalUsers = 1250,
    this.totalTechnicians = 85,
    this.totalBookings = 3420,
    this.activeBookings = 42,
    this.revenue = 125000.0,
    this.pendingApprovals = 8,
  });

  final int totalUsers;
  final int totalTechnicians;
  final int totalBookings;
  final int activeBookings;
  final double revenue;
  final int pendingApprovals;
}
