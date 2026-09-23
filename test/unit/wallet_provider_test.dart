import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/data/models/transaction_model.dart';
import 'package:fixsy_flutter/presentation/providers/wallet_provider.dart';

void main() {
  group('WalletProvider Unit Tests', () {
    late WalletProvider walletProvider;

    setUp(() {
      walletProvider = WalletProvider();
    });

    test('initializes with default fallback data and correct calculations', () {
      expect(walletProvider.transactions.isNotEmpty, true);
      expect(walletProvider.balance, greaterThan(0));
      expect(walletProvider.totalInflow, greaterThan(0));
      expect(walletProvider.totalOutflow, greaterThan(0));
    });

    test('filters transactions correctly for inflow and outflow', () {
      final all = walletProvider.getFilteredTransactions(0);
      final inflow = walletProvider.getFilteredTransactions(1);
      final outflow = walletProvider.getFilteredTransactions(2);

      expect(all.length, walletProvider.transactions.length);
      for (final t in inflow) {
        expect(t.amount, greaterThan(0));
      }
      for (final t in outflow) {
        expect(t.amount, lessThan(0));
      }
    });

    test('generates valid chart spots for fl_chart', () {
      final spots = walletProvider.getChartSpots();
      expect(spots.length, greaterThanOrEqualTo(6));
      for (final spot in spots) {
        expect(spot.x, greaterThanOrEqualTo(0));
        expect(spot.y, greaterThan(0));
      }
    });

    test('topUp increases balance and inserts topUp transaction', () async {
      final initialBalance = walletProvider.balance;
      const topUpAmount = 300.0;

      final success = await walletProvider.topUp(
        amount: topUpAmount,
        method: 'instapay',
      );

      expect(success, true);
      expect(walletProvider.balance, equals(initialBalance + topUpAmount));
      expect(walletProvider.transactions.first.type, TransactionType.topUp);
      expect(walletProvider.transactions.first.amount, equals(topUpAmount));
    });

    test('requestWithdrawal fails if amount is non-positive or exceeds balance', () async {
      final initialBalance = walletProvider.balance;

      final failZero = await walletProvider.requestWithdrawal(amount: 0);
      expect(failZero, false);

      final failNegative = await walletProvider.requestWithdrawal(amount: -50);
      expect(failNegative, false);

      final failExceed = await walletProvider.requestWithdrawal(amount: initialBalance + 10000);
      expect(failExceed, false);
    });

    test('requestWithdrawal succeeds within balance and updates transactions', () async {
      final initialBalance = walletProvider.balance;
      const withdrawAmount = 100.0;

      final success = await walletProvider.requestWithdrawal(
        amount: withdrawAmount,
        destinationType: 'wallet',
      );

      expect(success, true);
      expect(walletProvider.balance, equals(initialBalance - withdrawAmount));
      expect(walletProvider.transactions.first.type, TransactionType.withdrawal);
      expect(walletProvider.transactions.first.amount, equals(-withdrawAmount));
    });

    test('redeemVoucher applies valid coupon codes and rejects invalid ones', () async {
      final initialBalance = walletProvider.balance;

      // Invalid code
      final invalidTxn = await walletProvider.redeemVoucher('INVALID123');
      expect(invalidTxn, isNull);
      expect(walletProvider.balance, equals(initialBalance));

      // Valid FIXSY50
      final validTxn = await walletProvider.redeemVoucher('fixsy50');
      expect(validTxn, isNotNull);
      expect(validTxn!.amount, equals(50.0));
      expect(validTxn.type, TransactionType.reward);
      expect(walletProvider.balance, equals(initialBalance + 50.0));
    });
  });
}
