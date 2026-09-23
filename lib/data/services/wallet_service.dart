import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_logger.dart';
import '../models/transaction_model.dart';

class WalletService {
  WalletService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _instance {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference? get _transactionsRef => _instance?.collection('transactions');
  CollectionReference? get _withdrawalsRef => _instance?.collection('withdrawals');

  /// Stream transactions for a specific user in real-time
  Stream<List<TransactionModel>> streamTransactions(String userId) {
    final ref = _transactionsRef;
    if (ref == null) {
      return Stream.value(<TransactionModel>[]);
    }
    try {
      return ref
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList();
        // Sort descending by date locally to avoid composite index requirement
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      }).handleError((error) {
        AppLogger.error('Failed to stream transactions', error: error);
        return <TransactionModel>[];
      });
    } catch (e) {
      AppLogger.error('Error initiating transactions stream', error: e);
      return Stream.value(<TransactionModel>[]);
    }
  }

  /// Add a top-up transaction
  Future<TransactionModel> topUp({
    required String userId,
    required double amount,
    required String method,
  }) async {
    String methodLabel;
    switch (method.toLowerCase()) {
      case 'instapay':
        methodLabel = 'انستاباي';
        break;
      case 'wallet':
        methodLabel = 'فودافون كاش ومحافظ المحمول';
        break;
      case 'card':
        methodLabel = 'بطاقة بنكية';
        break;
      default:
        methodLabel = method;
    }

    final ref = _transactionsRef;
    final docId = ref != null ? ref.doc().id : DateTime.now().millisecondsSinceEpoch.toString();
    final txn = TransactionModel(
      id: docId,
      userId: userId,
      amount: amount,
      type: TransactionType.topUp,
      description: 'شحن رصيد - $methodLabel',
      date: DateTime.now(),
      status: 'completed',
      paymentMethod: method,
    );

    if (ref != null) {
      try {
        await ref.doc(docId).set(txn.toJson());
        AppLogger.info('Top-up successful: ${txn.id}');
      } catch (e) {
        AppLogger.warn('Firestore topUp offline or failed, returning model: $e');
      }
    }

    return txn;
  }

  /// Request a withdrawal
  Future<TransactionModel> requestWithdrawal({
    required String userId,
    required double amount,
    String destinationType = 'wallet',
  }) async {
    final ref = _transactionsRef;
    final wRef = _withdrawalsRef;
    final docId = ref != null ? ref.doc().id : DateTime.now().millisecondsSinceEpoch.toString();
    final wDocId = wRef != null ? wRef.doc().id : DateTime.now().millisecondsSinceEpoch.toString();

    final isBank = destinationType == 'bank';
    final description = isBank
        ? 'طلب سحب إلى الحساب البنكي'
        : 'طلب سحب إلى محفظة الهاتف';

    final txn = TransactionModel(
      id: docId,
      userId: userId,
      amount: -amount,
      type: TransactionType.withdrawal,
      description: description,
      date: DateTime.now(),
      status: 'pending',
      destinationType: destinationType,
    );

    if (wRef != null && ref != null) {
      try {
        await wRef.doc(wDocId).set({
          'id': wDocId,
          'userId': userId,
          'amount': amount,
          'destinationType': destinationType,
          'status': 'pending',
          'date': FieldValue.serverTimestamp(),
        });
        await ref.doc(docId).set(txn.toJson());
        AppLogger.info('Withdrawal request submitted: $wDocId');
      } catch (e) {
        AppLogger.warn('Firestore withdrawal request failed: $e');
      }
    }

    return txn;
  }

  /// Redeem promo / voucher code
  Future<TransactionModel?> redeemVoucher({
    required String userId,
    required String code,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    var bonus = 0.0;
    if (cleanCode == 'FIXSY50') {
      bonus = 50.0;
    } else if (cleanCode == 'WELCOME2026') {
      bonus = 100.0;
    } else if (cleanCode == 'BONUS20') {
      bonus = 20.0;
    } else {
      return null;
    }

    final ref = _transactionsRef;
    final docId = ref != null ? ref.doc().id : DateTime.now().millisecondsSinceEpoch.toString();
    final txn = TransactionModel(
      id: docId,
      userId: userId,
      amount: bonus,
      type: TransactionType.reward,
      description: 'كوبون هدية - $cleanCode',
      date: DateTime.now(),
      status: 'completed',
    );

    if (ref != null) {
      try {
        await ref.doc(docId).set(txn.toJson());
        AppLogger.info('Voucher redeemed: $cleanCode (+${bonus.toStringAsFixed(0)})');
      } catch (e) {
        AppLogger.warn('Firestore redeemVoucher failed: $e');
      }
    }

    return txn;
  }
}
