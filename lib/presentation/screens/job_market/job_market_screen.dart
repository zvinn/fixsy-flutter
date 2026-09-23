import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/market_job_model.dart';
import '../../providers/job_market_provider.dart';

/// Job Market Screen - Shows available jobs for technicians with bidding & negotiation
class JobMarketScreen extends StatefulWidget {
  const JobMarketScreen({super.key});

  @override
  State<JobMarketScreen> createState() => _JobMarketScreenState();
}

class _JobMarketScreenState extends State<JobMarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Job> _allJobs = [];
  List<Job> _nearbyJobs = [];
  List<Job> _urgentJobs = [];
  String _selectedFilter = 'الكل';

  final List<String> _serviceFilters = [
    'الكل',
    'سباكة',
    'كهرباء',
    'نجارة',
    'تكييف',
    'دهان',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 400));

    _allJobs = [
      Job(
        id: '1',
        title: 'إصلاح تسريب مياه',
        description: 'يوجد تسريب في أنبوب المياه أسفل المغسلة في المطبخ يحتاج كشف ومعالجة سريعة',
        serviceType: 'سباكة',
        location: 'المعادي، القاهرة',
        distance: 2.5,
        price: 150,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        clientName: 'أحمد محمد',
        isUrgent: true,
        bids: [
          JobBid(
            id: 'bid_101',
            jobId: '1',
            technicianId: 'tech_1',
            technicianName: 'م. حسام الدين',
            technicianRating: 4.9,
            proposedPrice: 140,
            arrivalTime: 'خلال 30 دقيقة ⚡',
            notes: 'شامل الكشف وقطع الغيار الأصلية مع ضمان شهر كامل',
            createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
            status: BidStatus.pending,
          ),
          JobBid(
            id: 'bid_102',
            jobId: '1',
            technicianId: 'tech_2',
            technicianName: 'م. خالد مصطفى',
            technicianRating: 4.8,
            proposedPrice: 160,
            arrivalTime: 'خلال ساعة ⏱️',
            notes: 'كشف بأحدث أجهزة الضغط والتسريب وضمان 3 أشهر',
            createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
            status: BidStatus.pending,
          ),
        ],
      ),
      Job(
        id: '2',
        title: 'تركيب نجفة وإضاءة ليد',
        description: 'تركيب نجفة جديدة في غرفة المعيشة مع توصيل الأسلاك ومفاتيح الديمر الذكية',
        serviceType: 'كهرباء',
        location: 'مدينة نصر، القاهرة',
        distance: 4.2,
        price: 200,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        clientName: 'سارة علي',
        bids: [
          JobBid(
            id: 'bid_201',
            jobId: '2',
            technicianId: 'tech_3',
            technicianName: 'م. طارق سعيد',
            technicianRating: 5.0,
            proposedPrice: 220,
            arrivalTime: 'خلال 45 دقيقة',
            notes: 'تركيب احترافي واختبار أحمال الإضاءة والتأريض',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            status: BidStatus.pending,
          ),
        ],
      ),
      Job(
        id: '3',
        title: 'إصلاح باب خشبي وتبديل كالون',
        description: 'باب غرفة النوم لا يغلق بشكل صحيح مع رغبة في استبدال الكالون بآخر حديث',
        serviceType: 'نجارة',
        location: 'الدقي، الجيزة',
        distance: 5.8,
        price: 120,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        clientName: 'محمود حسن',
        bids: const [],
      ),
      Job(
        id: '4',
        title: 'صيانة مكيف سبليت وشحن فريون',
        description: 'المكيف لا يبرد بشكل كافي ويصدر صوتاً خفيفاً مع الحاجة إلى تنظيف الفلاتر وشحن فريون R410',
        serviceType: 'تكييف',
        location: 'التجمع الخامس، القاهرة',
        distance: 8.1,
        price: 300,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        clientName: 'هاني عبدالله',
        isUrgent: true,
        bids: [
          JobBid(
            id: 'bid_401',
            jobId: '4',
            technicianId: 'tech_4',
            technicianName: 'م. إبراهيم كمال',
            technicianRating: 4.9,
            proposedPrice: 280,
            arrivalTime: 'خلال ساعة ونصف',
            notes: 'غسيل كيميائي للوحدة الخارجية وشحن فريون أمريكي أصلي',
            createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
            status: BidStatus.pending,
          ),
        ],
      ),
    ];

    _updateTabLists();
    setState(() => _isLoading = false);
  }

  void _updateTabLists() {
    _nearbyJobs = _allJobs.where((j) => j.distance <= 5).toList();
    _urgentJobs = _allJobs.where((j) => j.isUrgent).toList();
  }

  List<Job> _getFilteredJobs(List<Job> jobs) {
    if (_selectedFilter == 'الكل') return jobs;
    return jobs.where((j) => j.serviceType == _selectedFilter).toList();
  }

  void _submitBid(Job job, double price, String arrivalTime, String notes) {
    try {
      final provider = Provider.of<JobMarketProvider?>(context, listen: false);
      provider?.submitBid(
        jobId: job.id,
        proposedPrice: price,
        arrivalTime: arrivalTime,
        notes: notes,
      );
    } catch (_) {}

    final newBid = JobBid(
      id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
      jobId: job.id,
      technicianId: 'current_tech',
      technicianName: 'أنت (فني معتمد)',
      technicianRating: 5.0,
      proposedPrice: price,
      arrivalTime: arrivalTime,
      notes: notes.isNotEmpty ? notes : 'عرض فني متكامل مع ضمان الجودة',
      createdAt: DateTime.now(),
      status: BidStatus.pending,
    );

    setState(() {
      final index = _allJobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        final updatedBids = List<JobBid>.from(_allJobs[index].bids)..insert(0, newBid);
        _allJobs[index] = _allJobs[index].copyWith(bids: updatedBids);
        _updateTabLists();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال عرض السعر بقيمة ${price.toInt()} ج.م بنجاح! 🚀'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _acceptBid(Job job, JobBid bid) {
    try {
      final provider = Provider.of<JobMarketProvider?>(context, listen: false);
      provider?.acceptBid(jobId: job.id, bidId: bid.id);
    } catch (_) {}

    setState(() {
      final jobIndex = _allJobs.indexWhere((j) => j.id == job.id);
      if (jobIndex != -1) {
        final updatedBids = _allJobs[jobIndex].bids.map((b) {
          if (b.id == bid.id) {
            return b.copyWith(status: BidStatus.accepted);
          }
          return b;
        }).toList();
        _allJobs[jobIndex] = _allJobs[jobIndex].copyWith(bids: updatedBids);
        _updateTabLists();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم قبول عرض ${bid.technicianName} بقيمة ${bid.proposedPrice.toInt()} ج.م ✅'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _counterOffer(Job job, JobBid bid, double counterPrice, String counterNotes) {
    try {
      final provider = Provider.of<JobMarketProvider?>(context, listen: false);
      provider?.counterOffer(
        jobId: job.id,
        bidId: bid.id,
        counterPrice: counterPrice,
        counterNotes: counterNotes,
      );
    } catch (_) {}

    setState(() {
      final jobIndex = _allJobs.indexWhere((j) => j.id == job.id);
      if (jobIndex != -1) {
        final updatedBids = _allJobs[jobIndex].bids.map((b) {
          if (b.id == bid.id) {
            return b.copyWith(
              status: BidStatus.counterOffered,
              counterPrice: counterPrice,
              counterNotes: counterNotes,
            );
          }
          return b;
        }).toList();
        _allJobs[jobIndex] = _allJobs[jobIndex].copyWith(bids: updatedBids);
        _updateTabLists();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال العرض المقابل بقيمة ${counterPrice.toInt()} ج.م للفني 💬'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _acceptDirectJob(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('قبول الطلب المباشر', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
            const SizedBox(height: 12),
            Text('هل تريد قبول طلب "${job.title}" بالميزانية المقترحة ${job.price.toInt()} ج.م؟',
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitBid(job, job.price, 'خلال 30 دقيقة ⚡', 'قبول فوري بالميزانية المعلنة');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('تأكيد القبول', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSubmitBidModal(Job job) {
    final priceController = TextEditingController(text: job.price.toInt().toString());
    final notesController = TextEditingController();
    var selectedArrival = 'خلال 30 دقيقة ⚡';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تقديم عرض سعر فني',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            job.title,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الميزانية: ${job.price.toInt()} ج.م',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Quick price shortcuts
                const Text(
                  'اختر السعر المقترح أو أدخل سعراً مخصصاً:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPriceChip(
                      label: '${(job.price * 0.9).toInt()} ج.م (-10%)',
                      onTap: () => setModalState(() => priceController.text = (job.price * 0.9).toInt().toString()),
                    ),
                    const SizedBox(width: 8),
                    _buildPriceChip(
                      label: '${job.price.toInt()} ج.م (المطلوب)',
                      onTap: () => setModalState(() => priceController.text = job.price.toInt().toString()),
                    ),
                    const SizedBox(width: 8),
                    _buildPriceChip(
                      label: '${(job.price * 1.15).toInt()} ج.م (+15%)',
                      onTap: () => setModalState(() => priceController.text = (job.price * 1.15).toInt().toString()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price Input
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'قيمة العرض (ج.م)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Arrival Time
                const Text(
                  'وقت الحضور المتوقع:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'خلال 30 دقيقة ⚡',
                    'خلال ساعة ⏱️',
                    'اليوم مساءً 🌆',
                    'غداً صباحاً ☀️',
                  ].map((time) {
                    final isSelected = selectedArrival == time;
                    return InkWell(
                      onTap: () => setModalState(() => selectedArrival = time),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Notes Input
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات العرض والضمان (اختياري)',
                    hintText: 'مثال: شامل قطع الغيار الأصلية وضمان شهر...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final price = double.tryParse(priceController.text) ?? job.price;
                      Navigator.pop(ctx);
                      _submitBid(job, price, selectedArrival, notesController.text.trim());
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('إرسال عرض السعر للعميل 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceChip({required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showBidsModal(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final currentJob = _allJobs.firstWhere((j) => j.id == job.id, orElse: () => job);

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'العروض الفنية المقدمة',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            '${currentJob.bids.length} عروض متنافسة على هذا الطلب',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: currentJob.bids.isEmpty
                      ? const Center(
                          child: Text('لا توجد عروض مقدمة بعد لهذا الطلب'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: currentJob.bids.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final bid = currentJob.bids[index];
                            return _buildBidCard(
                              bid: bid,
                              job: currentJob,
                              onAccept: () {
                                Navigator.pop(ctx);
                                _acceptBid(currentJob, bid);
                              },
                              onCounterOffer: () {
                                _showCounterOfferDialog(context, currentJob, bid, () {
                                  setModalState(() {});
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBidCard({
    required JobBid bid,
    required Job job,
    required VoidCallback onAccept,
    required VoidCallback onCounterOffer,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bid.status == BidStatus.accepted
              ? Colors.green
              : (bid.status == BidStatus.counterOffered ? Colors.orange : Colors.grey.shade200),
          width: bid.status == BidStatus.accepted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: Text(
                  bid.technicianName[0],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.technicianName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${bid.technicianRating}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${bid.arrivalTime}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${bid.proposedPrice.toInt()} ج.م',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (bid.status == BidStatus.accepted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('مقبول ✅', style: TextStyle(fontSize: 10, color: Colors.green.shade800)),
                    )
                  else if (bid.status == BidStatus.counterOffered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('عرض مضاد 💬', style: TextStyle(fontSize: 10, color: Colors.orange.shade800)),
                    ),
                ],
              ),
            ],
          ),
          if (bid.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bid.notes,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
            ),
          ],
          if (bid.counterPrice != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.compare_arrows, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'عرضك المقابل: ${bid.counterPrice!.toInt()} ج.م (${bid.counterNotes ?? 'تفاوض'})',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade900, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (bid.status == BidStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('قبول العرض', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCounterOffer,
                    icon: const Icon(Icons.mode_comment_outlined, size: 16),
                    label: const Text('عرض مضاد', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade800,
                      side: BorderSide(color: Colors.orange.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showCounterOfferDialog(BuildContext context, Job job, JobBid bid, VoidCallback onUpdated) {
    final counterController = TextEditingController(text: (bid.proposedPrice * 0.9).toInt().toString());
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('إرسال عرض سعر مضاد', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('عرض الفني الحالي: ${bid.proposedPrice.toInt()} ج.م',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: counterController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'سعرك المقابل (ج.م)',
                prefixIcon: const Icon(Icons.monetization_on_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'رسالة التفاوض (اختياري)',
                hintText: 'مثال: أقصى ميزانية 150 ج.م شامل...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(counterController.text) ?? (bid.proposedPrice * 0.9);
              Navigator.pop(ctx);
              _counterOffer(job, bid, price, noteController.text.trim());
              onUpdated();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('إرسال العرض المقابل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPostJobModal(BuildContext context, JobMarketProvider? provider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final locationController = TextEditingController(text: 'المعادي، القاهرة');
    var selectedCategory = 'سباكة';
    var isUrgent = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'طرح طلب صيانة جديد للمناقصة 🛠️',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'سيتم عرض طلبك على أفضل الفنيين المعتمدين لتلقي عروض الأسعار التنافسية',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان الطلب (مثال: صيانة سخان غاز)',
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'قسم الصيانة',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'سباكة', child: Text('سباكة')),
                    DropdownMenuItem(value: 'كهرباء', child: Text('كهرباء')),
                    DropdownMenuItem(value: 'نجارة', child: Text('نجارة')),
                    DropdownMenuItem(value: 'تكييف', child: Text('تكييف وتبريد')),
                    DropdownMenuItem(value: 'دهان', child: Text('نقاشة ودهانات')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'وصف المشكلة بالتفصيل',
                    hintText: 'اشرح العطل أو ما تحتاج إلى إصلاحه بدقة...',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'الميزانية المتوقعة (ج.م)',
                          prefixIcon: const Icon(Icons.monetization_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'المنطقة / الحي',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('طلب صيانة عاجل ⚡', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('أولوية قصوى لوصول الفني بأسرع وقت', style: TextStyle(fontSize: 12)),
                  value: isUrgent,
                  activeThumbColor: Colors.red,
                  onChanged: (val) => setModalState(() => isUrgent = val),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final desc = descController.text.trim();
                      final loc = locationController.text.trim();
                      final price = double.tryParse(priceController.text) ?? 200.0;

                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى إدخال عنوان الطلب')),
                        );
                        return;
                      }

                      if (provider != null) {
                        provider.postJob(
                          title: title,
                          description: desc.isNotEmpty ? desc : title,
                          serviceType: selectedCategory,
                          location: loc.isNotEmpty ? loc : 'القاهرة',
                          price: price,
                          isUrgent: isUrgent,
                        );
                      }

                      final newJob = MarketJob(
                        id: 'job_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        description: desc.isNotEmpty ? desc : title,
                        serviceType: selectedCategory,
                        location: loc.isNotEmpty ? loc : 'القاهرة',
                        distance: 1.2,
                        price: price,
                        createdAt: DateTime.now(),
                        clientName: 'أنت (العميل)',
                        isUrgent: isUrgent,
                        bids: const [],
                      );

                      setState(() {
                        _allJobs.insert(0, newJob);
                        _updateTabLists();
                      });

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم طرح طلب الصيانة بنجاح في سوق المناقصات! 🚀'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: const Text('طرح الطلب للمناقصة الآن 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<JobMarketProvider?>(context);

    final allJobsList = provider != null && provider.allJobs.isNotEmpty
        ? _getFilteredJobs(provider.allJobs)
        : _getFilteredJobs(_allJobs);
    final nearbyJobsList = provider != null && provider.nearbyJobs.isNotEmpty
        ? _getFilteredJobs(provider.nearbyJobs)
        : _getFilteredJobs(_nearbyJobs);
    final urgentJobsList = provider != null && provider.urgentJobs.isNotEmpty
        ? _getFilteredJobs(provider.urgentJobs)
        : _getFilteredJobs(_urgentJobs);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showPostJobModal(context, provider),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add_task_rounded, color: Colors.white),
          label: const Text(
            'طلب صيانة جديد',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        appBar: AppBar(
          title: const Text('سوق العمل والمناقصات'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'قريب منك'),
              Tab(text: 'عاجل'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Filter Chips
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _serviceFilters.length,
                itemBuilder: (context, index) {
                  final filter = _serviceFilters[index];
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tab Views
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildJobList(allJobsList, isDark),
                        _buildJobList(nearbyJobsList, isDark),
                        _buildJobList(urgentJobsList, isDark),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(List<Job> jobs, bool isDark) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات متاحة حالياً',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _JobCard(
            job: job,
            isDark: isDark,
            onSubmitBid: () => _showSubmitBidModal(job),
            onViewBids: () => _showBidsModal(job),
            onAcceptDirect: () => _acceptDirectJob(job),
          ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isDark,
    required this.onSubmitBid,
    required this.onViewBids,
    required this.onAcceptDirect,
  });

  final Job job;
  final bool isDark;
  final VoidCallback onSubmitBid;
  final VoidCallback onViewBids;
  final VoidCallback onAcceptDirect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: job.isUrgent
              ? Colors.red.withValues(alpha: 0.5)
              : (isDark ? Colors.white12 : Colors.grey.shade200),
          width: job.isUrgent ? 2 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getServiceColor(job.serviceType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getServiceIcon(job.serviceType),
                    color: _getServiceColor(job.serviceType),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          if (job.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt, color: Colors.red, size: 14),
                                  SizedBox(width: 2),
                                  Text(
                                    'عاجل',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.serviceType,
                        style: TextStyle(
                          color: _getServiceColor(job.serviceType),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              job.description,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // Info Row & Bids Counter Chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.location_on,
                  label: '${job.distance} كم',
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.access_time,
                  label: _formatTime(job.createdAt),
                  isDark: isDark,
                ),
                const Spacer(),

                // Bids Count Badge Button
                InkWell(
                  onTap: onViewBids,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: job.bids.isNotEmpty ? Colors.teal.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: job.bids.isNotEmpty ? Colors.teal.shade300 : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 14,
                          color: job.bids.isNotEmpty ? Colors.teal.shade700 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${job.bids.length} عروض',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: job.bids.isNotEmpty ? Colors.teal.shade800 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Client Info & Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        job.clientName[0],
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.clientName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            job.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${job.price.toInt()} ج.م',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'الميزانية المقترحة',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSubmitBid,
                        icon: const Icon(Icons.local_offer_outlined, size: 16),
                        label: const Text('تقديم عرض سعر', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onAcceptDirect,
                        icon: const Icon(Icons.bolt, size: 16),
                        label: const Text('قبول مباشر'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getServiceColor(String type) {
    switch (type) {
      case 'سباكة':
        return Colors.blue;
      case 'كهرباء':
        return Colors.orange;
      case 'نجارة':
        return Colors.brown;
      case 'تكييف':
        return Colors.cyan;
      case 'دهان':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String type) {
    switch (type) {
      case 'سباكة':
        return Icons.plumbing;
      case 'كهرباء':
        return Icons.electrical_services;
      case 'نجارة':
        return Icons.carpenter;
      case 'تكييف':
        return Icons.ac_unit;
      case 'دهان':
        return Icons.format_paint;
      default:
        return Icons.build;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }
}
