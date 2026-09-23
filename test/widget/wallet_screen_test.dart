import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/screens/wallet/wallet_screen.dart';

void main() {
  group('WalletScreen Widget Tests', () {
    testWidgets('renders balance card and action buttons correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('المحفظة الرقمية'), findsOneWidget);
      expect(find.text('رصيد Fixsy Pay'), findsOneWidget);
      expect(find.text('شحن المحفظة'), findsOneWidget);
      expect(find.text('سحب الأموال'), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard), findsWidgets);
    });

    testWidgets('renders quick stats for inflow and outflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إجمالي الوارد'), findsOneWidget);
      expect(find.text('إجمالي المنصرف'), findsOneWidget);
    });

    testWidgets('allows switching transaction filters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('الوارد والشحن'), findsOneWidget);
      expect(find.text('المدفوعات والسحب'), findsOneWidget);

      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('الوارد والشحن'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('المدفوعات والسحب'));
      await tester.pumpAndSettle();
    });

    testWidgets('opens top-up bottom sheet when clicking charge button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('شحن المحفظة'));
      await tester.pumpAndSettle();

      expect(find.text('شحن رصيد المحفظة'), findsOneWidget);
      expect(find.text('انستاباي (InstaPay)'), findsOneWidget);
      expect(find.text('فودافون كاش ومحافظ المحمول'), findsOneWidget);
    });

    testWidgets('opens voucher dialog and validates promo code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WalletScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('استخدام كود خصم أو هدية'));
      await tester.pumpAndSettle();

      expect(find.text('كوبون أو كود هدية'), findsOneWidget);
      expect(find.text('تطبيق الكود'), findsOneWidget);
    });
  });
}
