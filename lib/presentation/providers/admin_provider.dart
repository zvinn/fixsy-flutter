import 'package:flutter/foundation.dart';
import '../../data/models/admin_model.dart';
import '../../data/services/admin_service.dart';

/// Provider for managing Fixsy Admin Panel state and operations
class AdminProvider extends ChangeNotifier {
  AdminProvider({AdminService? adminService})
      : _adminService = adminService ?? AdminService() {
    loadAllData();
  }

  final AdminService _adminService;

  bool _isLoading = false;
  String? _errorMessage;

  List<AdminTechnician> _pendingTechs = [];
  List<AdminTechnician> _debtors = [];
  List<AdminCoupon> _coupons = [];
  List<AdminDispute> _disputes = [];
  AdminPlatformStats _stats = const AdminPlatformStats();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AdminTechnician> get pendingTechs => List.unmodifiable(_pendingTechs);
  List<AdminTechnician> get debtors => List.unmodifiable(_debtors);
  List<AdminCoupon> get coupons => List.unmodifiable(_coupons);
  List<AdminDispute> get disputes => List.unmodifiable(_disputes);
  AdminPlatformStats get stats => _stats;

  int get pendingCount => _pendingTechs.length;
  double get totalDebt => _debtors.fold(0.0, (sum, t) => sum + t.debt);

  /// Load all admin dashboard data
  Future<void> loadAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _adminService.getPendingTechnicians(),
        _adminService.getDebtors(),
        _adminService.getCoupons(),
        _adminService.getDisputes(),
        _adminService.getPlatformStats(),
      ]);

      _pendingTechs = List<AdminTechnician>.from(results[0] as List<AdminTechnician>);
      _debtors = List<AdminTechnician>.from(results[1] as List<AdminTechnician>);
      _coupons = List<AdminCoupon>.from(results[2] as List<AdminCoupon>);
      _disputes = List<AdminDispute>.from(results[3] as List<AdminDispute>);
      _stats = results[4] as AdminPlatformStats;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve technician verification
  Future<bool> approveTech(String id) async {
    try {
      await _adminService.approveTechnician(id);
      _pendingTechs.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reject technician verification with smart reason
  Future<bool> rejectTech(String id, String reason) async {
    if (reason.trim().isEmpty) return false;
    try {
      await _adminService.rejectTechnician(id, reason.trim());
      _pendingTechs.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Settle debt for a technician
  Future<bool> settleDebt(String id) async {
    try {
      await _adminService.settleDebt(id);
      _debtors.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Add new coupon
  Future<bool> addCoupon(String code, double discount) async {
    if (code.trim().isEmpty || discount <= 0) return false;
    try {
      final coupon = await _adminService.addCoupon(code, discount);
      _coupons.add(coupon);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle coupon active status
  Future<bool> toggleCoupon(String id, bool currentStatus) async {
    try {
      await _adminService.toggleCouponStatus(id, currentStatus);
      final index = _coupons.indexWhere((c) => c.id == id);
      if (index != -1) {
        _coupons[index] = _coupons[index].copyWith(isActive: !currentStatus);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete coupon
  Future<bool> deleteCoupon(String id) async {
    try {
      await _adminService.deleteCoupon(id);
      _coupons.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Resolve dispute
  Future<bool> resolveDispute(String id) async {
    try {
      await _adminService.resolveDispute(id);
      _disputes.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Send broadcast notification
  Future<bool> sendBroadcast({
    required String title,
    required String body,
    required String targetGroup,
  }) async {
    if (title.trim().isEmpty || body.trim().isEmpty) return false;
    try {
      await _adminService.sendBroadcast(
        title: title.trim(),
        body: body.trim(),
        targetGroup: targetGroup,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
