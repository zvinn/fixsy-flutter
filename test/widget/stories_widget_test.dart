import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/widgets/stories/stories_widget.dart';

void main() {
  group('StoriesWidget Widget Tests', () {
    testWidgets('renders technician stories avatars and add story button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoriesWidget(userRole: 'client'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('أضف قصتك'), findsOneWidget);
      expect(find.text('م. أحمد حسني'), findsOneWidget);
      expect(find.text('م. محمود سامي'), findsOneWidget);
    });

    testWidgets('opens add story bottom sheet on tapping add button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoriesWidget(userRole: 'tech'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('أضف قصتك'));
      await tester.pumpAndSettle();

      expect(find.text('نشر قصة يومية جديدة (Story)'), findsOneWidget);
      expect(find.text('نشر القصة الآن'), findsOneWidget);
    });

    testWidgets('opens story viewer on tapping story avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StoriesWidget(userRole: 'client'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on first technician story
      await tester.tap(find.text('م. أحمد حسني'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show story viewer actions
      expect(find.text('طلب هذا الفني الآن'), findsOneWidget);
      expect(find.text('محادثة'), findsOneWidget);
    });
  });
}
