import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/providers/job_market_provider.dart';
import 'package:fixsy_flutter/data/models/market_job_model.dart';

void main() {
  group('JobMarketProvider Unit Tests', () {
    late JobMarketProvider provider;

    setUp(() {
      provider = JobMarketProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initializes with fallback market jobs', () {
      expect(provider.allJobs.isNotEmpty, isTrue);
      expect(provider.selectedCategory, 'الكل');
    });

    test('filters jobs by service category', () {
      provider.setCategoryFilter('سباكة');
      expect(provider.selectedCategory, 'سباكة');
      for (final job in provider.filteredAllJobs) {
        expect(job.serviceType, 'سباكة');
      }
    });

    test('filters jobs by search query in title and location', () {
      provider.setSearchQuery('تسريب');
      expect(provider.filteredAllJobs.any((j) => j.title.contains('تسريب')), isTrue);

      provider.setSearchQuery('مدينة نصر');
      expect(provider.filteredAllJobs.any((j) => j.location.contains('مدينة نصر')), isTrue);
    });

    test('extracts nearby jobs (<= 5km) and urgent jobs', () {
      final nearby = provider.nearbyJobs;
      expect(nearby.isNotEmpty, isTrue);
      for (final j in nearby) {
        expect(j.distance <= 5.0, isTrue);
      }

      final urgent = provider.urgentJobs;
      expect(urgent.isNotEmpty, isTrue);
      for (final j in urgent) {
        expect(j.isUrgent, isTrue);
      }
    });

    test('posts a new job into the market', () async {
      final initialCount = provider.allJobs.length;
      final newJob = await provider.postJob(
        title: 'صيانة مفاتيح كهرباء',
        description: 'تغيير لوحة القواطع الرئيسية للمنزل',
        serviceType: 'كهرباء',
        location: 'الشيخ زايد',
        price: 350.0,
        isUrgent: true,
      );

      expect(newJob.title, 'صيانة مفاتيح كهرباء');
      expect(provider.allJobs.length, initialCount + 1);
      expect(provider.allJobs.first.title, 'صيانة مفاتيح كهرباء');
    });

    test('submits a competitive bid on a job', () async {
      final targetJob = provider.allJobs.first;
      final initialBidsCount = targetJob.bids.length;

      await provider.submitBid(
        jobId: targetJob.id,
        proposedPrice: 199.0,
        arrivalTime: 'خلال 20 دقيقة ⚡',
        notes: 'معاينة مجانية وضمان سنة كاملة',
        techName: 'م. أحمد خالد',
      );

      final updatedJob = provider.allJobs.firstWhere((j) => j.id == targetJob.id);
      expect(updatedJob.bids.length, initialBidsCount + 1);
      expect(updatedJob.bids.any((b) => b.proposedPrice == 199.0), isTrue);
    });

    test('accepts a bid and updates job status to assigned', () async {
      final targetJob = provider.allJobs.firstWhere((j) => j.bids.length >= 2);
      final bidToAccept = targetJob.bids.first;

      await provider.acceptBid(
        jobId: targetJob.id,
        bidId: bidToAccept.id,
      );

      final updatedJob = provider.allJobs.firstWhere((j) => j.id == targetJob.id);
      expect(updatedJob.status, 'assigned');
      expect(updatedJob.bids.firstWhere((b) => b.id == bidToAccept.id).status, BidStatus.accepted);
      // Other bids should be rejected
      for (final b in updatedJob.bids.where((b) => b.id != bidToAccept.id)) {
        expect(b.status, BidStatus.rejected);
      }
    });

    test('counters an offer with negotiation price and notes', () async {
      final targetJob = provider.allJobs.firstWhere((j) => j.bids.isNotEmpty);
      final bidToCounter = targetJob.bids.first;

      await provider.counterOffer(
        jobId: targetJob.id,
        bidId: bidToCounter.id,
        counterPrice: 130.0,
        counterNotes: 'أقصى ميزانية 130 ج.م',
      );

      final updatedJob = provider.allJobs.firstWhere((j) => j.id == targetJob.id);
      final updatedBid = updatedJob.bids.firstWhere((b) => b.id == bidToCounter.id);
      expect(updatedBid.status, BidStatus.counterOffered);
      expect(updatedBid.counterPrice, 130.0);
      expect(updatedBid.counterNotes, 'أقصى ميزانية 130 ج.م');
    });
  });
}
