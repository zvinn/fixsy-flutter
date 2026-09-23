import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/widgets/scheduling/slot_scheduling_widget.dart';
import 'package:fixsy_flutter/presentation/widgets/scheduling/slot_scheduling_modal.dart';

void main() {
  group('SlotSchedulingWidget Tests', () {
    testWidgets('renders toggle buttons for now and scheduled booking', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SlotSchedulingWidget(
                onSchedulingChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('فوري الآن (30-60 دقيقة)'), findsOneWidget);
      expect(find.text('جدولة موعد مسبق'), findsOneWidget);
      expect(find.text('اختر تاريخ الزيارة'), findsOneWidget);
      expect(find.text('الفترة الزمنية المفضلة'), findsOneWidget);
      expect(find.text('تكرار الموعد تلقائياً'), findsOneWidget);
    });

    testWidgets('switching to now mode displays urgent arrival notice', (tester) async {
      SchedulingData? updatedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SlotSchedulingWidget(
                onSchedulingChanged: (data) {
                  updatedData = data;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on "فوري الآن"
      await tester.tap(find.text('فوري الآن (30-60 دقيقة)'));
      await tester.pumpAndSettle();

      expect(find.text('خدمة الصيانة السريعة والفورية'), findsOneWidget);
      expect(find.textContaining('30 - 60 دقيقة'), findsOneWidget);
      expect(updatedData?.bookingType, BookingType.now);
    });

    testWidgets('selecting time slots and recurrence options updates data correctly', (tester) async {
      SchedulingData? updatedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SlotSchedulingWidget(
                onSchedulingChanged: (data) {
                  updatedData = data;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select afternoon slot
      final afternoonSlot = find.text('الظهيرة 🌤️');
      await tester.ensureVisible(afternoonSlot);
      await tester.tap(afternoonSlot);
      await tester.pumpAndSettle();

      expect(updatedData?.timeSlot, '12:00 م - 04:00 م');

      // Select weekly recurring
      final weeklyChip = find.text('أسبوعياً');
      await tester.ensureVisible(weeklyChip);
      await tester.tap(weeklyChip);
      await tester.pumpAndSettle();

      expect(updatedData?.recurringType, RecurringType.weekly);
      expect(find.textContaining('سيتم تكرار هذا الحجز كل أسبوع'), findsOneWidget);
    });

    testWidgets('showSlotSchedulingBottomSheet opens and can confirm selection', (tester) async {
      SchedulingData? confirmedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  confirmedResult = await showSlotSchedulingBottomSheet(
                    context: context,
                    technicianName: 'م. أحمد حسني',
                    serviceTitle: 'صيانة سباكة',
                  );
                },
                child: const Text('افتح المودال'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open bottom sheet
      await tester.tap(find.text('افتح المودال'));
      await tester.pumpAndSettle();

      expect(find.text('تحديد موعد الخدمة'), findsOneWidget);
      expect(find.textContaining('م. أحمد حسني'), findsOneWidget);
      expect(find.text('تأكيد وحفظ الموعد المحدد'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('تأكيد وحفظ الموعد المحدد'));
      await tester.pumpAndSettle();

      expect(confirmedResult, isNotNull);
      expect(confirmedResult?.bookingType, BookingType.scheduled);
    });
  });
}
