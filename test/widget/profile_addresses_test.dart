import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/presentation/screens/addresses/addresses_screen.dart';
import 'package:fixsy_flutter/presentation/screens/addresses/add_address_screen.dart';
import 'package:fixsy_flutter/presentation/screens/profile/profile_screen.dart';
import 'package:fixsy_flutter/presentation/providers/address_provider.dart';
import 'package:fixsy_flutter/presentation/providers/wallet_provider.dart';
import 'package:fixsy_flutter/presentation/providers/loyalty_provider.dart';

void main() {
  group('Profile & Addresses Widget Tests', () {
    testWidgets('AddressesScreen renders address cards and default badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AddressProvider(),
            child: const AddressesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('العناوين المحفوظة'), findsOneWidget);
      expect(find.text('المنزل'), findsOneWidget);
      expect(find.text('العمل'), findsOneWidget);
      expect(find.text('العنوان الافتراضي'), findsOneWidget);
      expect(find.text('إضافة عنوان جديد'), findsOneWidget);
    });

    testWidgets('AddAddressScreen renders input fields and quick chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AddressProvider(),
            child: const AddAddressScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إضافة عنوان جديد'), findsOneWidget);
      expect(find.text('اسم العنوان (مثال: المنزل، العمل)'), findsNothing); // label text
      expect(find.text('المنزل 🏠'), findsOneWidget);
      expect(find.text('العمل 🏢'), findsOneWidget);
      expect(find.text('حفظ العنوان الآن'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders personal details, loyalty card, and links', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AddressProvider()),
              ChangeNotifierProvider(create: (_) => WalletProvider()),
              ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
            ],
            child: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الملف الشخصي'), findsOneWidget);
      expect(find.text('المعلومات الشخصية'), findsOneWidget);
      expect(find.text('العناوين المحفوظة'), findsOneWidget);
      expect(find.text('المحفظة والمدفوعات'), findsOneWidget);
      expect(find.text('دعوة الأصدقاء والمكافآت'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsOneWidget);
    });
  });
}
