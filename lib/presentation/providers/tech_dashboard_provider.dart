import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/tech_job_model.dart';
import '../../data/repositories/tech_repository_impl.dart';
import '../../domain/repositories/tech_repository.dart';

// Re-export model & status for backwards-compatibility with existing presentation code
export '../../data/models/tech_job_model.dart';

class TechDashboardProvider extends ChangeNotifier {
  TechDashboardProvider({ITechRepository? repository})
      : _repository = repository ?? TechRepositoryImpl() {
    _loadInitialFallbackData();
  }

  final ITechRepository _repository;

  String? _techEmail;
  bool _isAvailable = true;
  double _earnings = 2450.0;
  final double _debt = 50.0;
  final double _walletBalance = 1200.0;
  final double _rating = 4.9;
  final bool _isVerified = true;
  final String _specialty = 'تكييف وتبريد';
  String _workStartTime = '09:00';
  String _workEndTime = '21:00';
  List<String> _offDays = ['Friday'];

  List<TechJobModel> _jobs = [];
  final bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<TechJobModel>>? _subscription;

  // Getters
  List<TechJobModel> get jobs => _jobs;
  List<TechJobModel> get activeJobs => _jobs
      .where((j) => j.status != TechJobStatus.completed && j.status != TechJobStatus.cancelled)
      .toList();
  List<TechJobModel> get historyJobs => _jobs
      .where((j) => j.status == TechJobStatus.completed || j.status == TechJobStatus.cancelled)
      .toList();

  bool get isAvailable => _isAvailable;
  double get earnings => _earnings;
  double get debt => _debt;
  double get walletBalance => _walletBalance;
  double get rating => _rating;
  bool get isVerified => _isVerified;
  String get specialty => _specialty;
  String get workStartTime => _workStartTime;
  String get workEndTime => _workEndTime;
  List<String> get offDays => _offDays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _loadInitialFallbackData() {
    _jobs = [
      TechJobModel(
        id: 'tech-req-301',
        clientName: 'أحمد شريف',
        clientEmail: 'client.demo@fixsy.com',
        clientPhone: '01099887766',
        address: 'المعادي - دجلة، شارع 250',
        problemDesc: 'صيانة مكيف كاريير 2.25 حصان بارد ساخن مع تسريب مياه داخلي',
        price: 650.0,
        status: TechJobStatus.inProgress,
        date: DateTime.now().subtract(const Duration(minutes: 45)),
        scheduledDate: 'اليوم، 05:00 م',
        paymentMethod: 'wallet',
      ),
      TechJobModel(
        id: 'tech-req-302',
        clientName: 'م. سارة كمال',
        clientEmail: 'sara.k@gmail.com',
        clientPhone: '01122334455',
        address: 'التجمع الخامس - حي النرجس عمارة 8',
        problemDesc: 'تأسيس مواسير نحاس جنوب أفريقي ودفن كابلات لمكيفين',
        price: 1800.0,
        status: TechJobStatus.accepted,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        scheduledDate: 'غداً، 11:00 ص',
        paymentMethod: 'cash',
      ),
      TechJobModel(
        id: 'tech-req-303',
        clientName: 'د. خالد توفيق',
        clientEmail: 'khaled.t@yahoo.com',
        clientPhone: '01233445566',
        address: 'مصر الجديدة - ميدان روكسي',
        problemDesc: 'شحن فريون R22 لمكيف سبليت مع تنظيف الفلاتر بالبخار',
        price: 550.0,
        status: TechJobStatus.completed,
        date: DateTime.now().subtract(const Duration(hours: 28)),
        scheduledDate: 'أمس، 03:30 م',
        paymentMethod: 'cash',
      ),
    ];
    notifyListeners();
  }

  void initTech(String? email) {
    if (email == null || email.isEmpty) return;
    if (_techEmail == email && _subscription != null) return;

    _techEmail = email;
    _subscription?.cancel();

    _subscription = _repository.streamTechJobs(email).listen((list) {
      if (list.isNotEmpty) {
        _jobs = list;
      }
      notifyListeners();
    }, onError: (err) {
      AppLogger.error('Failed to stream tech requests: $err');
    });
  }

  /// Toggle availability
  void setAvailability(bool available) {
    _isAvailable = available;
    notifyListeners();

    final email = _techEmail;
    if (email != null) {
      _repository.updateAvailability(email, available);
    }
  }

  /// Update work schedule
  void updateSchedule({required String start, required String end, required List<String> offDays}) {
    _workStartTime = start;
    _workEndTime = end;
    _offDays = offDays;
    notifyListeners();

    final email = _techEmail;
    if (email != null) {
      _repository.updateSchedule(
        email,
        start: start,
        end: end,
        offDays: offDays,
      );
    }
  }

  /// Pipeline status transition
  Future<void> updateJobStatus(String jobId, TechJobStatus newStatus) async {
    final idx = _jobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      _jobs[idx] = _jobs[idx].copyWith(status: newStatus);

      // If completed, add price to earnings
      if (newStatus == TechJobStatus.completed) {
        _earnings += _jobs[idx].price;
      }
      notifyListeners();
    }

    try {
      await _repository.updateJobStatus(jobId, newStatus);
    } catch (e) {
      AppLogger.warn('Failed to update request status: $e');
    }
  }

  /// Next status in the work pipeline
  TechJobStatus getNextStatus(TechJobStatus current) {
    switch (current) {
      case TechJobStatus.pending:
        return TechJobStatus.accepted;
      case TechJobStatus.accepted:
        return TechJobStatus.onWay;
      case TechJobStatus.onWay:
        return TechJobStatus.arrived;
      case TechJobStatus.arrived:
        return TechJobStatus.inProgress;
      case TechJobStatus.inProgress:
        return TechJobStatus.completed;
      default:
        return current;
    }
  }

  /// 7-day earnings chart spots
  List<FlSpot> getEarningsChartSpots() {
    return const [
      FlSpot(0, 350),
      FlSpot(1, 550),
      FlSpot(2, 400),
      FlSpot(3, 750),
      FlSpot(4, 900),
      FlSpot(5, 650),
      FlSpot(6, 1200),
    ];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
