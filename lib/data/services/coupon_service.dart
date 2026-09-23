import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_logger.dart';

class CouponModel {

  CouponModel({
    required this.code,
    required this.expiryDate, this.discountAmount = 0,
    this.discountPercentage,
    this.isActive = true,
    this.maxUsage = 100,
    this.currentUsage = 0,
  });

  factory CouponModel.fromMap(Map<String, dynamic> data) {
    return CouponModel(
      code: data['code'] ?? '',
      discountAmount: (data['discount'] ?? 0).toDouble(),
      discountPercentage: data['percentage']?.toDouble(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      maxUsage: data['maxUsage'] ?? 100,
      currentUsage: data['currentUsage'] ?? 0,
    );
  }
  final String code;
  final double discountAmount;
  final double? discountPercentage;
  final DateTime expiryDate;
  final bool isActive;
  final int maxUsage;
  final int currentUsage;

  bool get isValid {
    if (!isActive) return false;
    if (DateTime.now().isAfter(expiryDate)) return false;
    if (currentUsage >= maxUsage) return false;
    return true;
  }
}

class CouponService {

  CouponService({FirebaseFirestore? firestore}) : _firestore = firestore;
  final FirebaseFirestore? _firestore;
  static const String _collection = 'coupons';

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<CouponModel?> validateCoupon(String code) async {
    try {
      final db = _db;
      if (db == null) return null;
      final querySnapshot = await db
          .collection(_collection)
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final data = querySnapshot.docs.first.data();
      final coupon = CouponModel.fromMap(data);

      if (!coupon.isValid) {
        AppLogger.info('Coupon $code is invalid or expired');
        return null; // Or throw notification exception
      }

      return coupon;
    } catch (e) {
      AppLogger.error('Error validating coupon: $e');
      return null;
    }
  }

  /// Calculate final price after discount
  double calculateDiscount(double originalPrice, CouponModel coupon) {
    if (coupon.discountPercentage != null) {
      final discount = originalPrice * (coupon.discountPercentage! / 100);
      return (originalPrice - discount).clamp(0, originalPrice).toDouble();
    } else {
      return (originalPrice - coupon.discountAmount).clamp(0, originalPrice).toDouble();
    }
  }
}
