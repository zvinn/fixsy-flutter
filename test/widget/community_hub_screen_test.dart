import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/presentation/screens/community/community_hub_screen.dart';
import 'package:fixsy_flutter/presentation/providers/community_provider.dart';

void main() {
  group('CommunityHubScreen Widget Tests', () {
    testWidgets('renders community hub screen with 3 tabs and daily tip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => CommunityProvider(),
            child: const CommunityHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مجتمع Fixsy'), findsOneWidget);
      expect(find.text('نصيحة اليوم'), findsWidgets);
      expect(find.text('أسئلة وأجوبة'), findsOneWidget);
      expect(find.text('أفكار ذكية (AI)'), findsOneWidget);
      expect(find.text('نصيحة اليوم المعتمدة'), findsOneWidget);
      expect(find.text('مشاركة'), findsOneWidget);
    });

    testWidgets('allows switching to Q&A tab and displays questions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => CommunityProvider(),
            child: const CommunityHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('أسئلة وأجوبة'));
      await tester.pumpAndSettle();

      expect(find.text('اطرح سؤالك أو استفسارك للفنيين والمجتمع'), findsOneWidget);
    });

    testWidgets('allows switching to AI tips tab and displays quick topics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => CommunityProvider(),
            child: const CommunityHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('أفكار ذكية (AI)'));
      await tester.pumpAndSettle();

      expect(find.text('مساعد Fixsy الذكي للصيانة'), findsOneWidget);
      expect(find.text('تسريب سباكة'), findsOneWidget);
      expect(find.text('تنظيف فلاتر التكييف'), findsOneWidget);
    });

    testWidgets('opens ask question modal when tapping on prompt button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => CommunityProvider(),
            child: const CommunityHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('أسئلة وأجوبة'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('اطرح سؤالك أو استفسارك للفنيين والمجتمع'));
      await tester.pumpAndSettle();

      expect(find.text('اطرح سؤالك للمجتمع'), findsOneWidget);
      expect(find.text('نشر السؤال الآن'), findsOneWidget);
    });
  });
}
