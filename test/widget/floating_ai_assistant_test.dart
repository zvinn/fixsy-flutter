import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/data/services/ai_service.dart';
import 'package:fixsy_flutter/presentation/widgets/ai/fixsy_ai_assistant_modal.dart';
import 'package:fixsy_flutter/presentation/providers/auth_provider.dart';
import 'package:fixsy_flutter/presentation/providers/service_request_provider.dart';
import 'package:fixsy_flutter/presentation/screens/home/home_screen.dart';

void main() {
  group('AiDiagnosis & AiService Logic Tests', () {
    test('Heuristic diagnosis returns correct category, price range, and advice for plumbing', () async {
      final aiService = AiService();
      final diagnosis = await aiService.analyzeProblem(
        images: [],
        description: 'عندي تسريب مياه شديد من ماسورة الحمام تحت الحوض',
      );

      expect(diagnosis.suggestedService, equals('سباكة'));
      expect(diagnosis.icon, equals('💧'));
      expect(diagnosis.severity, equals('high'));
      expect(diagnosis.minPrice, greaterThan(0));
      expect(diagnosis.maxPrice, greaterThan(diagnosis.minPrice));
      expect(diagnosis.advice, contains('محبس المياه'));
      expect(diagnosis.tips, isNotEmpty);
    });

    test('Heuristic diagnosis returns critical severity for electrical faults', () async {
      final aiService = AiService();
      final diagnosis = await aiService.analyzeProblem(
        images: [],
        description: 'في ماس كهربائي والفيشة مطلعّة شرار وقفلة في القاطع',
      );

      expect(diagnosis.suggestedService, equals('كهرباء'));
      expect(diagnosis.icon, equals('⚡'));
      expect(diagnosis.severity, equals('critical'));
      expect(diagnosis.advice, contains('القاطع الرئيسي'));
    });

    test('AiService askAiFollowUp answers questions about materials, safety and duration', () async {
      final aiService = AiService();
      final diagnosis = await aiService.analyzeProblem(
        images: [],
        description: 'تسريب مياه',
      );

      final materialAnswer = await aiService.askAiFollowUp(
        query: 'هل السعر يشمل الخامات وقطع الغيار؟',
        contextDiagnosis: diagnosis,
      );
      expect(materialAnswer, contains('الأسعار التقديرية'));
      expect(materialAnswer, contains('قطع الغيار'));

      final safetyAnswer = await aiService.askAiFollowUp(
        query: 'هل المشكلة فيها خطر؟',
        contextDiagnosis: diagnosis,
      );
      expect(safetyAnswer, contains('السلامة'));

      final durationAnswer = await aiService.askAiFollowUp(
        query: 'كم يستغرق الإصلاح؟',
        contextDiagnosis: diagnosis,
      );
      expect(durationAnswer, contains('دقيقة'));
    });
  });

  group('FloatingAiAssistantButton & Modal Widget Tests', () {
    testWidgets('FloatingAiAssistantButton renders and opens FixsyAiAssistantModal on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: const FloatingAiAssistantButton(enableAnimation: false),
            body: Container(),
          ),
        ),
      );

      expect(find.byKey(const Key('floating_ai_assistant_btn')), findsOneWidget);
      expect(find.text('مساعد Fixsy الذكي'), findsOneWidget);

      await tester.tap(find.byKey(const Key('floating_ai_assistant_btn')));
      await tester.pumpAndSettle();

      // Modal should now be open
      expect(find.byType(FixsyAiAssistantModal), findsOneWidget);
      expect(find.byKey(const Key('ai_assistant_query_input')), findsOneWidget);
      expect(find.byKey(const Key('ai_assistant_analyze_btn')), findsOneWidget);
    });

    testWidgets('Tapping quick triage chip analyzes problem and renders diagnosis result', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FixsyAiAssistantModal(),
          ),
        ),
      );

      // Verify triage chips exist
      expect(find.text('💧 تسريب مياه بالحمام / المطبخ'), findsOneWidget);

      // Tap triage chip
      await tester.tap(find.text('💧 تسريب مياه بالحمام / المطبخ'));
      await tester.pumpAndSettle();

      // Verify diagnosis results rendered
      expect(find.textContaining('تشخيص: سباكة'), findsOneWidget);
      expect(find.text('التكلفة التقديرية المتوقعة'), findsOneWidget);
      expect(find.textContaining('ج.م'), findsOneWidget);
      expect(find.textContaining('إجراءات أمان فورية'), findsOneWidget);
      expect(find.byKey(const Key('ai_assistant_smart_book_btn')), findsOneWidget);
      expect(find.byKey(const Key('ai_assistant_job_market_btn')), findsOneWidget);
    });

    testWidgets('Follow-up Q&A and image attachment work correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FixsyAiAssistantModal(),
          ),
        ),
      );

      // Test image attachment toggle
      await tester.tap(find.byKey(const Key('ai_assistant_image_btn')));
      await tester.pump();
      expect(find.text('صورة_العطل_المرفقة.jpg'), findsOneWidget);

      // Type query & analyze
      await tester.enterText(
        find.byKey(const Key('ai_assistant_query_input')),
        'تكييف مش بيسقع وبيسرب ماء',
      );
      await tester.tap(find.byKey(const Key('ai_assistant_analyze_btn')));
      await tester.pumpAndSettle();

      expect(find.textContaining('تشخيص: تكييف'), findsOneWidget);

      // Ask follow-up question
      expect(find.text('هل السعر يشمل الخامات المطلوبة؟'), findsOneWidget);
      await tester.tap(find.text('هل السعر يشمل الخامات المطلوبة؟'));
      await tester.pumpAndSettle();

      // Verify question and AI answer bubble appear
      expect(find.text('هل السعر يشمل الخامات المطلوبة؟'), findsWidgets);
      expect(find.textContaining('الأسعار التقديرية'), findsOneWidget);

      // Test reset button
      await tester.tap(find.byKey(const Key('ai_assistant_reset_btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ai_assistant_smart_book_btn')), findsNothing);
      expect(find.text('💧 تسريب مياه بالحمام / المطبخ'), findsOneWidget);
    });

    testWidgets('Smart Book button triggers booking callback with diagnosis parameters', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool booked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FixsyAiAssistantModal(
              initialQuery: 'باب خشب مكسور ومفصلات بايظة',
              onBookTechnician: () {
                booked = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('تشخيص: نجارة'), findsOneWidget);
      expect(find.byKey(const Key('ai_assistant_smart_book_btn')), findsOneWidget);

      await tester.tap(find.byKey(const Key('ai_assistant_smart_book_btn')));
      await tester.pumpAndSettle();

      expect(booked, isTrue);
    });
  });
}
