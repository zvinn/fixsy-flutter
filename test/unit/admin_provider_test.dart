import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/providers/admin_provider.dart';

void main() {
  group('AdminProvider Unit Tests', () {
    late AdminProvider adminProvider;

    setUp(() {
      adminProvider = AdminProvider();
    });

    test('initializes with mock data and calculates stats', () async {
      await adminProvider.loadAllData();

      expect(adminProvider.pendingTechs.isNotEmpty, isTrue);
      expect(adminProvider.debtors.isNotEmpty, isTrue);
      expect(adminProvider.coupons.isNotEmpty, isTrue);
      expect(adminProvider.disputes.isNotEmpty, isTrue);
      expect(adminProvider.pendingCount, greaterThan(0));
      expect(adminProvider.totalDebt, greaterThan(0));
    });

    test('approves a pending technician', () async {
      await adminProvider.loadAllData();
      final initialCount = adminProvider.pendingCount;
      final techId = adminProvider.pendingTechs.first.id;

      final success = await adminProvider.approveTech(techId);

      expect(success, isTrue);
      expect(adminProvider.pendingCount, equals(initialCount - 1));
      expect(adminProvider.pendingTechs.any((t) => t.id == techId), isFalse);
    });

    test('rejects a pending technician with smart reason', () async {
      await adminProvider.loadAllData();
      final initialCount = adminProvider.pendingCount;
      final techId = adminProvider.pendingTechs.first.id;

      final success = await adminProvider.rejectTech(
        techId,
        'صورة بطاقة الرقم القومي غير واضحة',
      );

      expect(success, isTrue);
      expect(adminProvider.pendingCount, equals(initialCount - 1));
    });

    test('settles debt for a debtor technician', () async {
      await adminProvider.loadAllData();
      final initialDebtorsCount = adminProvider.debtors.length;
      final debtorId = adminProvider.debtors.first.id;

      final success = await adminProvider.settleDebt(debtorId);

      expect(success, isTrue);
      expect(adminProvider.debtors.length, equals(initialDebtorsCount - 1));
    });

    test('adds a new coupon successfully', () async {
      await adminProvider.loadAllData();
      final initialCount = adminProvider.coupons.length;

      final success = await adminProvider.addCoupon('SUPER25', 25.0);

      expect(success, isTrue);
      expect(adminProvider.coupons.length, equals(initialCount + 1));
      expect(adminProvider.coupons.any((c) => c.code == 'SUPER25'), isTrue);
    });

    test('toggles coupon active status', () async {
      await adminProvider.loadAllData();
      final coupon = adminProvider.coupons.first;
      final oldStatus = coupon.isActive;

      final success = await adminProvider.toggleCoupon(coupon.id, oldStatus);

      expect(success, isTrue);
      final updated = adminProvider.coupons.firstWhere((c) => c.id == coupon.id);
      expect(updated.isActive, equals(!oldStatus));
    });

    test('deletes a coupon from system', () async {
      await adminProvider.loadAllData();
      final couponId = adminProvider.coupons.first.id;
      final initialCount = adminProvider.coupons.length;

      final success = await adminProvider.deleteCoupon(couponId);

      expect(success, isTrue);
      expect(adminProvider.coupons.length, equals(initialCount - 1));
    });

    test('resolves a dispute ticket', () async {
      await adminProvider.loadAllData();
      final disputeId = adminProvider.disputes.first.id;
      final initialCount = adminProvider.disputes.length;

      final success = await adminProvider.resolveDispute(disputeId);

      expect(success, isTrue);
      expect(adminProvider.disputes.length, equals(initialCount - 1));
    });

    test('sends a broadcast notification', () async {
      final success = await adminProvider.sendBroadcast(
        title: 'عرض الجمعة البيضاء',
        body: 'خصم 30% على كافة خدمات التكييف',
        targetGroup: 'all',
      );

      expect(success, isTrue);
    });
  });
}
