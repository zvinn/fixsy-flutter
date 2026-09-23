import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixsy_flutter/presentation/widgets/booking/booking_modal.dart';
import 'package:fixsy_flutter/presentation/providers/service_request_provider.dart';
import 'package:fixsy_flutter/presentation/providers/auth_provider.dart';
import 'package:fixsy_flutter/presentation/widgets/scheduling/slot_scheduling_widget.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRequestProvider()),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: BookingModal(initialServiceType: 'plumbing'),
        ),
      ),
    );
  }

  group('BookingModal Scheduling Integration Tests', () {
    testWidgets('renders booking modal header and steps', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('حجز خدمة'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('advancing to step 1 renders SlotSchedulingWidget', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Next to advance to step 1 (details & scheduling)
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(SlotSchedulingWidget), findsOneWidget);
      expect(find.text('فوري الآن (30-60 دقيقة)'), findsOneWidget);
      expect(find.text('جدولة موعد مسبق'), findsOneWidget);
    });
  });
}
