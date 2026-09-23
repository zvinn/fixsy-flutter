import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_logger.dart';
import '../models/market_job_model.dart';

class JobMarketService {
  FirebaseFirestore? get _instance {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // In-memory store for fallback / testing / demo
  final List<MarketJob> _inMemoryJobs = [
    MarketJob(
      id: 'job_1',
      title: 'إصلاح تسريب مياه بالمطبخ',
      description: 'يوجد تسريب في أنبوب المياه أسفل المغسلة في المطبخ يحتاج كشف ومعالجة سريعة',
      serviceType: 'سباكة',
      location: 'المعادي، القاهرة',
      distance: 2.5,
      price: 150.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      clientId: 'client_101',
      clientName: 'أحمد محمد',
      isUrgent: true,
      bids: [
        JobBid(
          id: 'bid_101',
          jobId: 'job_1',
          technicianId: 'tech_1',
          technicianName: 'م. حسام الدين',
          technicianRating: 4.9,
          proposedPrice: 140.0,
          arrivalTime: 'خلال 30 دقيقة ⚡',
          notes: 'شامل الكشف وقطع الغيار الأصلية مع ضمان شهر كامل',
          createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
          status: BidStatus.pending,
        ),
        JobBid(
          id: 'bid_102',
          jobId: 'job_1',
          technicianId: 'tech_2',
          technicianName: 'م. خالد مصطفى',
          technicianRating: 4.8,
          proposedPrice: 160.0,
          arrivalTime: 'خلال ساعة ⏱️',
          notes: 'كشف بأحدث أجهزة الضغط والتسريب وضمان 3 أشهر',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          status: BidStatus.pending,
        ),
      ],
    ),
    MarketJob(
      id: 'job_2',
      title: 'تركيب نجفة وإضاءة ليد ذكية',
      description: 'تركيب نجفة جديدة في غرفة المعيشة مع توصيل الأسلاك ومفاتيح الديمر الذكية',
      serviceType: 'كهرباء',
      location: 'مدينة نصر، القاهرة',
      distance: 4.2,
      price: 200.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      clientId: 'client_102',
      clientName: 'سارة علي',
      bids: [
        JobBid(
          id: 'bid_201',
          jobId: 'job_2',
          technicianId: 'tech_3',
          technicianName: 'م. طارق سعيد',
          technicianRating: 5.0,
          proposedPrice: 220.0,
          arrivalTime: 'خلال 45 دقيقة',
          notes: 'تركيب احترافي واختبار أحمال الإضاءة والتأريض',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          status: BidStatus.pending,
        ),
      ],
    ),
    MarketJob(
      id: 'job_3',
      title: 'إصلاح باب خشبي وتبديل كالون',
      description: 'باب غرفة النوم لا يغلق بشكل صحيح مع رغبة في استبدال الكالون بآخر حديث',
      serviceType: 'نجارة',
      location: 'الدقي، الجيزة',
      distance: 5.8,
      price: 120.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      clientId: 'client_103',
      clientName: 'محمود حسن',
      bids: const [],
    ),
    MarketJob(
      id: 'job_4',
      title: 'صيانة مكيف سبليت وشحن فريون',
      description: 'المكيف لا يبرد بشكل كافي ويصدر صوتاً خفيفاً مع الحاجة إلى تنظيف الفلاتر وشحن فريون R410',
      serviceType: 'تكييف',
      location: 'التجمع الخامس، القاهرة',
      distance: 8.1,
      price: 300.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      clientId: 'client_104',
      clientName: 'هاني عبدالله',
      isUrgent: true,
      bids: [
        JobBid(
          id: 'bid_401',
          jobId: 'job_4',
          technicianId: 'tech_4',
          technicianName: 'م. إبراهيم كمال',
          technicianRating: 4.9,
          proposedPrice: 280.0,
          arrivalTime: 'خلال ساعة ونصف',
          notes: 'تنظيف شامل للوحدتين الداخلية والخارجية وضغط فريون أمريكي',
          createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
          status: BidStatus.pending,
        ),
      ],
    ),
    MarketJob(
      id: 'job_5',
      title: 'دهان حائط ديكوري في الصالون',
      description: 'دهان جوتن قطيفة على حائط رئيسي بمساحة 4×3 متر مع معالجة الشقوق مسبقاً',
      serviceType: 'دهان',
      location: 'المهندسين، الجيزة',
      distance: 3.4,
      price: 450.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      clientId: 'client_105',
      clientName: 'مروة الشريف',
      bids: const [],
    ),
  ];

  /// Stream of active market jobs
  Stream<List<MarketJob>> getJobsStream() {
    final firestore = _instance;
    if (firestore == null) {
      return Stream.value(List.unmodifiable(_inMemoryJobs));
    }

    try {
      return firestore
          .collection('market_jobs')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map<List<MarketJob>>((snapshot) {
            if (snapshot.docs.isEmpty) {
              return List<MarketJob>.unmodifiable(_inMemoryJobs);
            }
            return snapshot.docs.map<MarketJob>((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return MarketJob.fromJson(data);
            }).toList();
          })
          .handleError((e) {
            AppLogger.warn('Error reading market_jobs from firestore, using mock: $e');
            return List<MarketJob>.unmodifiable(_inMemoryJobs);
          });
    } catch (e) {
      AppLogger.warn('Firestore stream failed: $e');
      return Stream.value(List<MarketJob>.unmodifiable(_inMemoryJobs));
    }
  }

  /// Create / Post a new job
  Future<MarketJob> postJob({
    required String title,
    required String description,
    required String serviceType,
    required String location,
    required double price,
    required String clientId,
    required String clientName,
    bool isUrgent = false,
  }) async {
    final newJob = MarketJob(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      serviceType: serviceType,
      location: location,
      distance: 1.5,
      price: price,
      createdAt: DateTime.now(),
      clientId: clientId,
      clientName: clientName,
      isUrgent: isUrgent,
      status: 'open',
      bids: const [],
    );

    _inMemoryJobs.insert(0, newJob);

    final firestore = _instance;
    if (firestore != null) {
      try {
        await firestore.collection('market_jobs').doc(newJob.id).set(newJob.toJson());
      } catch (e) {
        AppLogger.warn('Failed to persist job to firestore: $e');
      }
    }

    return newJob;
  }

  /// Submit a bid / offer from a technician
  Future<void> submitBid({
    required String jobId,
    required String technicianId,
    required String technicianName,
    required double proposedPrice,
    required String arrivalTime,
    required String notes,
    double technicianRating = 4.9,
  }) async {
    final newBid = JobBid(
      id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      technicianId: technicianId,
      technicianName: technicianName,
      technicianRating: technicianRating,
      proposedPrice: proposedPrice,
      arrivalTime: arrivalTime,
      notes: notes,
      createdAt: DateTime.now(),
      status: BidStatus.pending,
    );

    final jobIndex = _inMemoryJobs.indexWhere((j) => j.id == jobId);
    if (jobIndex != -1) {
      final updatedBids = List<JobBid>.from(_inMemoryJobs[jobIndex].bids)..add(newBid);
      _inMemoryJobs[jobIndex] = _inMemoryJobs[jobIndex].copyWith(bids: updatedBids);
    }

    final firestore = _instance;
    if (firestore != null) {
      try {
        await firestore.collection('market_jobs').doc(jobId).update({
          'bids': FieldValue.arrayUnion([newBid.toJson()]),
        });
      } catch (e) {
        AppLogger.warn('Failed to add bid in firestore: $e');
      }
    }
  }

  /// Accept an offer/bid
  Future<void> acceptBid({
    required String jobId,
    required String bidId,
  }) async {
    final jobIndex = _inMemoryJobs.indexWhere((j) => j.id == jobId);
    if (jobIndex != -1) {
      final currentJob = _inMemoryJobs[jobIndex];
      String? acceptedTechId;
      final updatedBids = currentJob.bids.map((b) {
        if (b.id == bidId) {
          acceptedTechId = b.technicianId;
          return b.copyWith(status: BidStatus.accepted);
        } else {
          return b.copyWith(status: BidStatus.rejected);
        }
      }).toList();

      _inMemoryJobs[jobIndex] = currentJob.copyWith(
        status: 'assigned',
        assignedTechId: acceptedTechId,
        bids: updatedBids,
      );
    }

    final firestore = _instance;
    if (firestore != null) {
      try {
        final jobDoc = await firestore.collection('market_jobs').doc(jobId).get();
        if (jobDoc.exists) {
          final data = jobDoc.data();
          if (data != null && data['bids'] is List) {
            final bids = (data['bids'] as List).map((b) {
              if (b['id'] == bidId) {
                b['status'] = BidStatus.accepted.name;
              } else {
                b['status'] = BidStatus.rejected.name;
              }
              return b;
            }).toList();

            await firestore.collection('market_jobs').doc(jobId).update({
              'status': 'assigned',
              'bids': bids,
            });
          }
        }
      } catch (e) {
        AppLogger.warn('Failed to accept bid in firestore: $e');
      }
    }
  }

  /// Counter offer on a bid
  Future<void> counterOffer({
    required String jobId,
    required String bidId,
    required double counterPrice,
    required String counterNotes,
  }) async {
    final jobIndex = _inMemoryJobs.indexWhere((j) => j.id == jobId);
    if (jobIndex != -1) {
      final currentJob = _inMemoryJobs[jobIndex];
      final updatedBids = currentJob.bids.map((b) {
        if (b.id == bidId) {
          return b.copyWith(
            status: BidStatus.counterOffered,
            counterPrice: counterPrice,
            counterNotes: counterNotes,
          );
        }
        return b;
      }).toList();

      _inMemoryJobs[jobIndex] = currentJob.copyWith(bids: updatedBids);
    }
  }
}
