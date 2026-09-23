import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider({WalletService? walletService})
      : _walletService = walletService ?? WalletService() {
    _loadInitialFallbackData();
  }

  final WalletService _walletService;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;
  StreamSubscription<List<TransactionModel>>? _subscription;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get balance {
    if (_transactions.isEmpty) return 0.0;
    return _transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalInflow {
    return _transactions
        .where((t) => t.amount > 0)
        .fold(0.0, (acc, t) => acc + t.amount);
  }

  double get totalOutflow {
    return _transactions
        .where((t) => t.amount < 0)
        .fold(0.0, (acc, t) => acc + t.amount.abs());
  }

  /// Initialize real-time sync with user ID
  void initUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      _currentUserId = null;
      _subscription?.cancel();
      _loadInitialFallbackData();
      return;
    }

    if (_currentUserId == userId && _subscription != null) return;

    _currentUserId = userId;
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _walletService.streamTransactions(userId).listen(
      (data) {
        if (data.isNotEmpty) {
          _transactions = data;
        } else if (_transactions.isEmpty) {
          _loadInitialFallbackData();
        }
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Initial realistic fallback data for demo / offline
  void _loadInitialFallbackData() {
    _transactions = [
      TransactionModel(
        id: '1',
        userId: _currentUserId ?? 'demo',
        description: 'شحن رصيد - فودافون كاش',
        amount: 500.0,
        type: TransactionType.topUp,
        date: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      TransactionModel(
        id: '2',
        userId: _currentUserId ?? 'demo',
        description: 'خدمة سباكة - كود حجز #8291',
        amount: -350.0,
        type: TransactionType.payment,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: '3',
        userId: _currentUserId ?? 'demo',
        description: 'مكافأة ترحيبية - كود FIXSY50',
        amount: 50.0,
        type: TransactionType.reward,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TransactionModel(
        id: '4',
        userId: _currentUserId ?? 'demo',
        description: 'سحب إلى الحساب البنكي',
        amount: -500.0,
        type: TransactionType.withdrawal,
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      TransactionModel(
        id: '5',
        userId: _currentUserId ?? 'demo',
        description: 'خدمة صيانة تكييف - علي حسن',
        amount: 450.0,
        type: TransactionType.earning,
        date: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
    notifyListeners();
  }

  /// Filter transactions by category: 0=All, 1=Inflow, 2=Outflow
  List<TransactionModel> getFilteredTransactions(int filterIndex) {
    if (filterIndex == 1) {
      return _transactions.where((t) => t.amount > 0).toList();
    } else if (filterIndex == 2) {
      return _transactions.where((t) => t.amount < 0).toList();
    }
    return _transactions;
  }

  /// Generate spots for FlChart
  List<FlSpot> getChartSpots() {
    if (_transactions.isEmpty) {
      return const [
        FlSpot(0, 400),
        FlSpot(1, 650),
        FlSpot(2, 500),
        FlSpot(3, 850),
        FlSpot(4, 950),
        FlSpot(5, 1250),
      ];
    }

    final recent = _transactions.take(6).toList().reversed.toList();
    var running = 200.0;
    final spots = <FlSpot>[];
    for (var i = 0; i < recent.length; i++) {
      running += recent[i].amount;
      if (running < 0) running = 50.0;
      spots.add(FlSpot(i.toDouble(), running));
    }
    while (spots.length < 6) {
      spots.insert(0, const FlSpot(0, 300.0));
      for (var i = 0; i < spots.length; i++) {
        spots[i] = FlSpot(i.toDouble(), spots[i].y);
      }
    }
    return spots;
  }

  /// Top Up
  Future<bool> topUp({required double amount, required String method}) async {
    final userId = _currentUserId ?? 'demo_user';
    final txn = await _walletService.topUp(
      userId: userId,
      amount: amount,
      method: method,
    );
    _transactions.insert(0, txn);
    notifyListeners();
    return true;
  }

  /// Withdraw
  Future<bool> requestWithdrawal({
    required double amount,
    String destinationType = 'wallet',
  }) async {
    if (amount <= 0 || amount > balance) return false;

    final userId = _currentUserId ?? 'demo_user';
    final txn = await _walletService.requestWithdrawal(
      userId: userId,
      amount: amount,
      destinationType: destinationType,
    );
    _transactions.insert(0, txn);
    notifyListeners();
    return true;
  }

  /// Redeem voucher
  Future<TransactionModel?> redeemVoucher(String code) async {
    final userId = _currentUserId ?? 'demo_user';
    final txn = await _walletService.redeemVoucher(userId: userId, code: code);
    if (txn != null) {
      _transactions.insert(0, txn);
      notifyListeners();
    }
    return txn;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
