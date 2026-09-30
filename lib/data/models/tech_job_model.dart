import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a job assigned to a technician
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

/// Model representing a technician job
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
