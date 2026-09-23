import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/screens/technician/technician_profile_screen.dart';

void main() {
  group('TechnicianProfileScreen Widget Tests', () {
    testWidgets('renders technician profile header and basic details', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TechnicianProfileScreen(
            techName: 'م. حسام حسن',
            specialty: 'خبير التكييف والتبريد',
            area: 'مدينة نصر والتجمع',
            rating: 4.8,
            completedJobs: 180,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('م. حسام حسن'), findsOneWidget);
      expect(find.text('خبير التكييف والتبريد'), findsOneWidget);
      expect(find.text('مدينة نصر والتجمع'), findsOneWidget);
      expect(find.text('4.8 ⭐'), findsOneWidget);
      expect(find.text('+180'), findsOneWidget);
      expect(find.text('محادثة الفني'), findsOneWidget);
      expect(find.text('طلب حجز مع الفني'), findsOneWidget);
    });

    testWidgets('renders trust badges and skills in info tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TechnicianProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('نبذة عن الفني'), findsOneWidget);
      expect(find.text('فني موثق بالهوية الوطنية'), findsOneWidget);
      expect(find.text('شهادة Fixsy الاحترافية للسلامة'), findsOneWidget);
      expect(find.text('المهارات والتخصصات'), findsOneWidget);
    });

    testWidgets('switches to portfolio tab and renders works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TechnicianProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on portfolio tab
      await tester.tap(find.text('معرض الأعمال'));
      await tester.pumpAndSettle();

      expect(find.text('تأسيس شبكة مياه وصرف متكاملة'), findsOneWidget);
      expect(find.text('سباكة وتشطيبات'), findsOneWidget);
    });

    testWidgets('switches to reviews tab and renders ratings breakdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TechnicianProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on reviews tab
      await tester.tap(find.text('التقييمات'));
      await tester.pumpAndSettle();

      expect(find.text('5 نجوم'), findsOneWidget);
      expect(find.text('كريم عبد الرحمن'), findsOneWidget);
    });

    testWidgets('opens call dialog on pressing direct call button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TechnicianProfileScreen(phone: '+201199887766'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('اتصال مباشر'));
      await tester.pumpAndSettle();

      expect(find.text('اتصال بالفني'), findsOneWidget);
      expect(find.text('+201199887766'), findsOneWidget);
      expect(find.text('اتصال الآن'), findsOneWidget);
    });
  });
}
