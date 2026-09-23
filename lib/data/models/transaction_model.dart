import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  earning,
  withdrawal,
  payment,
  topUp,
  reward;

  static TransactionType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'earning':
        return TransactionType.earning;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'payment':
        return TransactionType.payment;
      case 'topup':
      case 'top_up':
        return TransactionType.topUp;
      case 'reward':
        return TransactionType.reward;
      default:
        return TransactionType.payment;
    }
  }

  String toValueString() {
    switch (this) {
      case TransactionType.earning:
        return 'earning';
      case TransactionType.withdrawal:
        return 'withdrawal';
      case TransactionType.payment:
        return 'payment';
      case TransactionType.topUp:
        return 'topUp';
      case TransactionType.reward:
        return 'reward';
    }
  }
}

class TransactionModel {
  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.status = 'completed',
    this.destinationType,
    this.paymentMethod,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime parsedDate;
    final rawDate = json['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    final rawAmount = json['amount'];
    var parsedAmount = 0.0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    }

    return TransactionModel(
      id: id ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      amount: parsedAmount,
      type: TransactionType.fromString(json['type'] as String? ?? 'payment'),
      description: json['description'] as String? ?? '',
      date: parsedDate,
      status: json['status'] as String? ?? 'completed',
      destinationType: json['destinationType'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
    );
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TransactionModel.fromJson(data, id: doc.id);
  }

  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime date;
  final String status;
  final String? destinationType;
  final String? paymentMethod;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toValueString(),
      'description': description,
      'date': Timestamp.fromDate(date),
      'status': status,
      if (destinationType != null) 'destinationType': destinationType,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionType? type,
    String? description,
    DateTime? date,
    String? status,
    String? destinationType,
    String? paymentMethod,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      destinationType: destinationType ?? this.destinationType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
