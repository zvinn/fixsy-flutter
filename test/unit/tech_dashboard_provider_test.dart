import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/providers/tech_dashboard_provider.dart';

void main() {
  group('TechDashboardProvider Unit Tests', () {
    late TechDashboardProvider provider;

    setUp(() {
      provider = TechDashboardProvider();
    });

    test('initializes with default metrics and fallback requests', () {
      expect(provider.jobs.isNotEmpty, isTrue);
      expect(provider.earnings, greaterThan(0));
      expect(provider.debt, greaterThanOrEqualTo(0));
      expect(provider.walletBalance, greaterThan(0));
      expect(provider.isAvailable, isTrue);
      expect(provider.isVerified, isTrue);
    });

    test('splits active and history jobs correctly', () {
      final active = provider.activeJobs;
      final history = provider.historyJobs;

      expect(active.length + history.length, equals(provider.jobs.length));
      for (final j in active) {
        expect(j.status, isNot(TechJobStatus.completed));
        expect(j.status, isNot(TechJobStatus.cancelled));
      }
      for (final j in history) {
        expect(j.status == TechJobStatus.completed || j.status == TechJobStatus.cancelled, isTrue);
      }
    });

    test('setAvailability toggles availability flag', () {
      provider.setAvailability(false);
      expect(provider.isAvailable, isFalse);

      provider.setAvailability(true);
      expect(provider.isAvailable, isTrue);
    });

    test('updateSchedule updates start, end, and off-days', () {
      provider.updateSchedule(
        start: '08:00',
        end: '18:00',
        offDays: ['Friday', 'Saturday'],
      );

      expect(provider.workStartTime, equals('08:00'));
      expect(provider.workEndTime, equals('18:00'));
      expect(provider.offDays, contains('Saturday'));
    });

    test('status pipeline transitions correctly', () {
      expect(provider.getNextStatus(TechJobStatus.pending), equals(TechJobStatus.accepted));
      expect(provider.getNextStatus(TechJobStatus.accepted), equals(TechJobStatus.onWay));
      expect(provider.getNextStatus(TechJobStatus.onWay), equals(TechJobStatus.arrived));
      expect(provider.getNextStatus(TechJobStatus.arrived), equals(TechJobStatus.inProgress));
      expect(provider.getNextStatus(TechJobStatus.inProgress), equals(TechJobStatus.completed));
    });

    test('updateJobStatus advances status and increases earnings on completion', () async {
      final initialEarnings = provider.earnings;
      final targetJob = provider.activeJobs.first;

      await provider.updateJobStatus(targetJob.id, TechJobStatus.completed);

      final updated = provider.jobs.firstWhere((j) => j.id == targetJob.id);
      expect(updated.status, equals(TechJobStatus.completed));
      expect(provider.earnings, equals(initialEarnings + targetJob.price));
    });

    test('getEarningsChartSpots provides 7 daily points', () {
      final spots = provider.getEarningsChartSpots();
      expect(spots.length, equals(7));
      for (final s in spots) {
        expect(s.x, greaterThanOrEqualTo(0));
        expect(s.y, greaterThan(0));
      }
    });
  });
}
