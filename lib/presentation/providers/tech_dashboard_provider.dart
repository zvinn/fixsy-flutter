import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/app_logger.dart';

enum TechJobStatus {
  pending,
  accepted,
  onWay,
  arrived,
  inProgress,
  completed,
  cancelled;

  static TechJobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return TechJobStatus.accepted;
      case 'on_way':
      case 'onway':
        return TechJobStatus.onWay;
      case 'arrived':
        return TechJobStatus.arrived;
      case 'in_progress':
      case 'inprogress':
        return TechJobStatus.inProgress;
      case 'completed':
        return TechJobStatus.completed;
      case 'cancelled':
        return TechJobStatus.cancelled;
      default:
        return TechJobStatus.pending;
    }
  }

  String toValueString() {
    switch (this) {
      case TechJobStatus.pending:
        return 'pending';
      case TechJobStatus.accepted:
        return 'accepted';
      case TechJobStatus.onWay:
        return 'on_way';
      case TechJobStatus.arrived:
        return 'arrived';
      case TechJobStatus.inProgress:
        return 'in_progress';
      case TechJobStatus.completed:
        return 'completed';
      case TechJobStatus.cancelled:
        return 'cancelled';
    }
  }

  String get labelArabic {
    switch (this) {
      case TechJobStatus.pending:
        return 'في الانتظار';
      case TechJobStatus.accepted:
        return 'تم القبول';
      case TechJobStatus.onWay:
        return 'في الطريق';
      case TechJobStatus.arrived:
        return 'وصلت للموقع';
      case TechJobStatus.inProgress:
        return 'جاري العمل';
      case TechJobStatus.completed:
        return 'مكتمل';
      case TechJobStatus.cancelled:
        return 'ملغي';
    }
  }
}

class TechJobModel {
  TechJobModel({
    required this.id,
    required this.clientName,
    required this.address,
    required this.problemDesc,
    required this.price,
    required this.status,
    required this.date,
    this.clientPhone,
    this.clientEmail,
    this.scheduledDate,
    this.paymentMethod = 'cash',
  });

  factory TechJobModel.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime parsedDate;
    final rawDate = json['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawPrice = json['price'];
    var parsedPrice = 0.0;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice) ?? 0.0;
    }

    return TechJobModel(
      id: id ?? json['id'] as String? ?? '',
      clientName: json['client_name'] as String? ?? json['clientName'] as String? ?? 'عميل فيكسي',
      clientPhone: json['client_phone'] as String? ?? json['clientPhone'] as String?,
      clientEmail: json['client_email'] as String? ?? json['clientEmail'] as String?,
      address: json['client_address'] as String? ?? json['address'] as String? ?? 'القاهرة',
      problemDesc: json['problem_desc'] as String? ?? json['problemDesc'] as String? ?? 'صيانة منزلية',
      price: parsedPrice,
      status: TechJobStatus.fromString(json['status'] as String? ?? 'pending'),
      date: parsedDate,
      scheduledDate: json['scheduledDate'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
    );
  }

  factory TechJobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TechJobModel.fromJson(data, id: doc.id);
  }

  final String id;
  final String clientName;
  final String? clientPhone;
  final String? clientEmail;
  final String address;
  final String problemDesc;
  final double price;
  final TechJobStatus status;
  final DateTime date;
  final String? scheduledDate;
  final String paymentMethod;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      if (clientPhone != null) 'client_phone': clientPhone,
      if (clientEmail != null) 'client_email': clientEmail,
      'client_address': address,
      'problem_desc': problemDesc,
      'price': price,
      'status': status.toValueString(),
      'date': Timestamp.fromDate(date),
      if (scheduledDate != null) 'scheduledDate': scheduledDate,
      'paymentMethod': paymentMethod,
    };
  }

  TechJobModel copyWith({
    String? id,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? address,
    String? problemDesc,
    double? price,
    TechJobStatus? status,
    DateTime? date,
    String? scheduledDate,
    String? paymentMethod,
  }) {
    return TechJobModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      address: address ?? this.address,
      problemDesc: problemDesc ?? this.problemDesc,
      price: price ?? this.price,
      status: status ?? this.status,
      date: date ?? this.date,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class TechDashboardProvider extends ChangeNotifier {
  TechDashboardProvider({FirebaseFirestore? firestore}) : _firestore = firestore {
    _loadInitialFallbackData();
  }

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _instance {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

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
  StreamSubscription<QuerySnapshot>? _subscription;

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

    final inst = _instance;
    if (inst == null) return;

    try {
      _subscription = inst
          .collection('requests')
          .where('technician_email', isEqualTo: email)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs.map((doc) => TechJobModel.fromFirestore(doc)).toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          _jobs = list;
        }
        notifyListeners();
      }, onError: (err) {
        AppLogger.error('Failed to stream tech requests: $err');
      });
    } catch (e) {
      AppLogger.warn('Firestore streaming offline for tech: $e');
    }
  }

  /// Toggle availability
  void setAvailability(bool available) {
    _isAvailable = available;
    notifyListeners();

    final inst = _instance;
    final email = _techEmail;
    if (inst != null && email != null) {
      inst.collection('technicians').doc(email).set({
        'isAvailable': available,
      }, SetOptions(merge: true)).catchError((e) {
        AppLogger.warn('Failed to update availability in Firestore: $e');
      });
    }
  }

  /// Update work schedule
  void updateSchedule({required String start, required String end, required List<String> offDays}) {
    _workStartTime = start;
    _workEndTime = end;
    _offDays = offDays;
    notifyListeners();

    final inst = _instance;
    final email = _techEmail;
    if (inst != null && email != null) {
      inst.collection('technicians').doc(email).set({
        'workingHours': {
          'start': start,
          'end': end,
          'offDays': offDays,
        }
      }, SetOptions(merge: true)).catchError((e) {
        AppLogger.warn('Failed to update schedule in Firestore: $e');
      });
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

    final inst = _instance;
    if (inst != null) {
      try {
        await inst.collection('requests').doc(jobId).update({
          'status': newStatus.toValueString(),
        });
      } catch (e) {
        AppLogger.warn('Failed to update request status in Firestore: $e');
      }
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
