import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';

/// Admin Service for managing Fixsy backend operations
class AdminService {
  AdminService({FirebaseFirestore? firestore}) : _firestore = firestore;

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

  // In-memory mock store for offline/testing/graceful fallback
  final List<AdminTechnician> _mockTechnicians = [
    const AdminTechnician(
      id: 'tech_01',
      name: 'كريم محمود السعدني',
      email: 'karim.tech@fixsy.com',
      specialty: 'تكييف وتبريد',
      nationalId: '29408151203491',
      isVerified: 'pending',
      debt: 0.0,
      rating: 4.8,
      experience: '5 سنوات',
    ),
    const AdminTechnician(
      id: 'tech_02',
      name: 'أيمن سمير القاضي',
      email: 'ayman.plumber@fixsy.com',
      specialty: 'سباكة وصحي',
      nationalId: '29104021405521',
      isVerified: 'pending',
      debt: 0.0,
      rating: 4.5,
      experience: '3 سنوات',
    ),
    const AdminTechnician(
      id: 'tech_03',
      name: 'طارق عبد الله الشريف',
      email: 'tarek.electric@fixsy.com',
      specialty: 'كهرباء منازل',
      nationalId: '28912101602931',
      isVerified: 'pending',
      debt: 0.0,
      rating: 4.9,
      experience: '7 سنوات',
    ),
    const AdminTechnician(
      id: 'debtor_01',
      name: 'مصطفى حسين فهمي',
      email: 'mostafa.tech@fixsy.com',
      specialty: 'صيانة أجهزة منزلية',
      nationalId: '29305141804211',
      isVerified: true,
      debt: 450.0,
      unpaidOrdersCount: 3,
      rating: 4.2,
      experience: '4 سنوات',
    ),
    const AdminTechnician(
      id: 'debtor_02',
      name: 'هيثم فؤاد الجمال',
      email: 'haitham.paint@fixsy.com',
      specialty: 'نقاشة ودهانات',
      nationalId: '29007191209381',
      isVerified: true,
      debt: 820.0,
      unpaidOrdersCount: 5,
      rating: 4.6,
      experience: '6 سنوات',
    ),
  ];

  final List<AdminCoupon> _mockCoupons = [
    const AdminCoupon(
      id: 'cpn_01',
      code: 'FIXSY20',
      discount: 20.0,
      isActive: true,
      expiryDate: '2026-12-31',
    ),
    const AdminCoupon(
      id: 'cpn_02',
      code: 'WELCOME10',
      discount: 10.0,
      isActive: true,
      expiryDate: '2026-12-31',
    ),
    const AdminCoupon(
      id: 'cpn_03',
      code: 'SUMMER50',
      discount: 50.0,
      isActive: false,
      expiryDate: '2026-08-31',
    ),
  ];

  final List<AdminDispute> _mockDisputes = [
    const AdminDispute(
      id: 'disp_01',
      reqId: 'REQ-9042',
      clientEmail: 'ahmed.client@fixsy.com',
      techId: 'debtor_01',
      reason: 'الفني تأخر ساعتين عن الموعد المحدد دون إبلاغ مسبق',
      date: '2026-09-20',
      status: 'pending',
    ),
    const AdminDispute(
      id: 'disp_02',
      reqId: 'REQ-8831',
      clientEmail: 'mona.user@fixsy.com',
      techId: 'tech_02',
      reason: 'لم يتم استكمال تصليح تسريب المياه بالكامل',
      date: '2026-09-18',
      status: 'pending',
    ),
  ];

  /// Fetch pending technician verification applications
  Future<List<AdminTechnician>> getPendingTechnicians() async {
    final fs = firestore;
    if (fs == null) {
      return _mockTechnicians.where((t) => t.isPending).toList();
    }

    try {
      final snap = await fs
          .collection('technicians')
          .where('isVerified', isEqualTo: 'pending')
          .get();

      if (snap.docs.isEmpty) {
        return _mockTechnicians.where((t) => t.isPending).toList();
      }

      return snap.docs
          .map((d) => AdminTechnician.fromJson({...d.data(), 'id': d.id}))
          .toList();
    } catch (_) {
      return _mockTechnicians.where((t) => t.isPending).toList();
    }
  }

  /// Approve technician verification
  Future<void> approveTechnician(String id) async {
    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('technicians').doc(id).update({
          'isVerified': true,
          'approvedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }

    final index = _mockTechnicians.indexWhere((t) => t.id == id);
    if (index != -1) {
      _mockTechnicians[index] = _mockTechnicians[index].copyWith(
        isVerified: true,
      );
    }
  }

  /// Reject technician verification with smart reason
  Future<void> rejectTechnician(String id, String reason) async {
    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('technicians').doc(id).update({
          'isVerified': false,
          'rejectionReason': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }

    final index = _mockTechnicians.indexWhere((t) => t.id == id);
    if (index != -1) {
      _mockTechnicians[index] = _mockTechnicians[index].copyWith(
        isVerified: false,
        rejectionReason: reason,
      );
    }
  }

  /// Fetch technicians who owe debt to Fixsy platform
  Future<List<AdminTechnician>> getDebtors() async {
    final fs = firestore;
    if (fs == null) {
      final list = _mockTechnicians.where((t) => t.debt > 0).toList();
      list.sort((a, b) => b.debt.compareTo(a.debt));
      return list;
    }

    try {
      final snap = await fs
          .collection('technicians')
          .where('debt', isGreaterThan: 0)
          .orderBy('debt', descending: true)
          .get();

      if (snap.docs.isEmpty) {
        return _mockTechnicians.where((t) => t.debt > 0).toList();
      }

      return snap.docs
          .map((d) => AdminTechnician.fromJson({...d.data(), 'id': d.id}))
          .toList();
    } catch (_) {
      return _mockTechnicians.where((t) => t.debt > 0).toList();
    }
  }

  /// Settle technician debt
  Future<void> settleDebt(String id) async {
    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('technicians').doc(id).update({
          'debt': 0.0,
          'unpaidOrdersCount': 0,
          'lastSettledAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }

    final index = _mockTechnicians.indexWhere((t) => t.id == id);
    if (index != -1) {
      _mockTechnicians[index] = _mockTechnicians[index].copyWith(
        debt: 0.0,
        unpaidOrdersCount: 0,
      );
    }
  }

  /// Fetch discount coupons
  Future<List<AdminCoupon>> getCoupons() async {
    final fs = firestore;
    if (fs == null) {
      return List<AdminCoupon>.from(_mockCoupons);
    }

    try {
      final snap = await fs.collection('coupons').get();
      if (snap.docs.isEmpty) {
        return List<AdminCoupon>.from(_mockCoupons);
      }
      return snap.docs
          .map((d) => AdminCoupon.fromJson({...d.data(), 'id': d.id}))
          .toList();
    } catch (_) {
      return List<AdminCoupon>.from(_mockCoupons);
    }
  }

  /// Add new promo coupon
  Future<AdminCoupon> addCoupon(String code, double discount) async {
    final newCoupon = AdminCoupon(
      id: 'cpn_${DateTime.now().millisecondsSinceEpoch}',
      code: code.trim().toUpperCase(),
      discount: discount,
      isActive: true,
      expiryDate: '2026-12-31',
    );

    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('coupons').doc(newCoupon.id).set(newCoupon.toJson());
      } catch (_) {}
    }

    _mockCoupons.add(newCoupon);
    return newCoupon;
  }

  /// Toggle coupon active status
  Future<void> toggleCouponStatus(String id, bool currentStatus) async {
    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('coupons').doc(id).update({
          'isActive': !currentStatus,
        });
      } catch (_) {}
    }

    final index = _mockCoupons.indexWhere((c) => c.id == id);
    if (index != -1) {
      _mockCoupons[index] = _mockCoupons[index].copyWith(
        isActive: !currentStatus,
      );
    }
  }

  /// Delete coupon
  Future<void> deleteCoupon(String id) async {
    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('coupons').doc(id).delete();
      } catch (_) {}
    }

    _mockCoupons.removeWhere((c) => c.id == id);
  }

  /// Fetch disputes
  Future<List<AdminDispute>> getDisputes() async {
    final fs = firestore;
    if (fs == null) {
      return List<AdminDispute>.from(_mockDisputes);
    }

    try {
      final snap = await fs.collection('disputes').get();
      if (snap.docs.isEmpty) {
        return List<AdminDispute>.from(_mockDisputes);
      }
      return snap.docs
          .map((d) => AdminDispute.fromJson({...d.data(), 'id': d.id}))
          .toList();
    } catch (_) {
      return List<AdminDispute>.from(_mockDisputes);
    }
  }

  /// Resolve dispute
  Future<void> resolveDispute(String id) async {
    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('disputes').doc(id).delete();
      } catch (_) {}
    }

    _mockDisputes.removeWhere((d) => d.id == id);
  }

  /// Send broadcast push notification
  Future<void> sendBroadcast({
    required String title,
    required String body,
    required String targetGroup, // 'all', 'techs', 'clients'
  }) async {
    final fs = firestore;
    if (fs != null) {
      try {
        await fs.collection('broadcasts').add({
          'title': title,
          'body': body,
          'targetGroup': targetGroup,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }

  /// Fetch platform stats
  Future<AdminPlatformStats> getPlatformStats() async {
    return const AdminPlatformStats();
  }
}
