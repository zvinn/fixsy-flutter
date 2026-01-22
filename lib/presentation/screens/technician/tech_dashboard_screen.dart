import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TechDashboardScreen extends StatefulWidget {
  const TechDashboardScreen({super.key});

  @override
  State<TechDashboardScreen> createState() => _TechDashboardScreenState();
}

class _TechDashboardScreenState extends State<TechDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAvailable = true;

  // Mock Data
  final double _earnings = 2450.0;
  final double _debt = 50.0;
  final double _walletBalance = 1200.0;

  final List<TechJob> _jobs = [
    TechJob(
      id: '1',
      clientName: 'أحمد محمد',
      address: 'شارع التحرير، المعادي',
      problemDesc: 'تسريب في الحمام الرئيسي',
      price: 350.0,
      status: JobStatus.pending,
      date: DateTime.now(),
      paymentMethod: 'cash',
    ),
    TechJob(
      id: '2',
      clientName: 'سارة أحمد',
      address: 'مدينة نصر، بلوك 5',
      problemDesc: 'مشكلة في الكهرباء - القاطع يفصل',
      price: 250.0,
      status: JobStatus.accepted,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      paymentMethod: 'wallet',
    ),
    TechJob(
      id: '3',
      clientName: 'محمود علي',
      address: 'الدقي، شارع التحرير',
      problemDesc: 'صيانة تكييف سبليت',
      price: 500.0,
      status: JobStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMethod: 'cash',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeJobs = _jobs.where((j) => j.status != JobStatus.completed && j.status != JobStatus.cancelled).toList();
    final historyJobs = _jobs.where((j) => j.status == JobStatus.completed || j.status == JobStatus.cancelled).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('المهام اليومية'),
          ],
        ),
        centerTitle: true,
        actions: [
          // Availability Toggle
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Text(
                  _isAvailable ? 'متاح' : 'غير متاح',
                  style: TextStyle(
                    color: _isAvailable ? AppTheme.successColor : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() => _isAvailable = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value ? 'أنت الآن متاح للطلبات' : 'أنت الآن غير متاح'),
                      ),
                    );
                  },
                  activeColor: AppTheme.successColor,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Wallet Card
          _buildWalletCard(),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '🚀 نشطة (${activeJobs.length})'),
              const Tab(text: '📜 السجل'),
            ],
          ),

          // Job Lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJobsList(activeJobs),
                _buildJobsList(historyJobs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/wallet'),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الأرباح', '$_earnings ج.م', Colors.white),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildStatItem('المحفظة', '$_walletBalance ج.م', Colors.white),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildStatItem('المستحق', '$_debt ج.م', Colors.red.shade300),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تفاصيل المعاملات',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_left, color: Colors.white70, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildJobsList(List<TechJob> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.navigation_outlined, size: 40, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text('لا توجد مهام', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _buildJobCard(jobs[index]),
    );
  }

  Widget _buildJobCard(TechJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.clientName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(job.status),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: job.paymentMethod == 'wallet'
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      job.paymentMethod == 'wallet' ? Icons.credit_card : Icons.money,
                      size: 14,
                      color: job.paymentMethod == 'wallet' ? Colors.blue : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.paymentMethod == 'wallet' ? 'محفظة' : 'نقدي',
                      style: TextStyle(
                        fontSize: 12,
                        color: job.paymentMethod == 'wallet' ? Colors.blue : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(Icons.location_on_outlined, 'العنوان', job.address),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.access_time,
                  'الموعد',
                  '${job.date.hour}:${job.date.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Problem Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.build_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.problemDesc,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('السعر', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    Text(
                      '${job.price.toStringAsFixed(0)} ج.م',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          _buildActionButton(job),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
            Text(
              value.length > 15 ? '${value.substring(0, 15)}...' : value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(JobStatus status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['text'],
        style: TextStyle(color: config['color'], fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return {'text': 'في الانتظار', 'color': Colors.orange, 'bg': Colors.orange.shade50};
      case JobStatus.accepted:
        return {'text': 'تم القبول', 'color': Colors.blue, 'bg': Colors.blue.shade50};
      case JobStatus.onWay:
        return {'text': 'في الطريق', 'color': Colors.cyan, 'bg': Colors.cyan.shade50};
      case JobStatus.arrived:
        return {'text': 'وصلت', 'color': Colors.purple, 'bg': Colors.purple.shade50};
      case JobStatus.inProgress:
        return {'text': 'جاري العمل', 'color': Colors.amber.shade700, 'bg': Colors.amber.shade50};
      case JobStatus.completed:
        return {'text': 'مكتمل', 'color': Colors.green, 'bg': Colors.green.shade50};
      case JobStatus.cancelled:
        return {'text': 'ملغي', 'color': Colors.red, 'bg': Colors.red.shade50};
    }
  }

  Widget _buildActionButton(TechJob job) {
    if (job.status == JobStatus.completed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '🎉 تم إكمال المهمة بنجاح',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (job.status == JobStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '❌ تم إلغاء الطلب',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    }

    final nextStatus = _getNextStatus(job.status);
    final buttonConfig = _getButtonConfig(nextStatus);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _updateJobStatus(job, nextStatus),
        icon: Icon(buttonConfig['icon']),
        label: Text(buttonConfig['text']),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonConfig['color'],
          padding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  JobStatus _getNextStatus(JobStatus current) {
    switch (current) {
      case JobStatus.pending:
        return JobStatus.accepted;
      case JobStatus.accepted:
        return JobStatus.onWay;
      case JobStatus.onWay:
        return JobStatus.arrived;
      case JobStatus.arrived:
        return JobStatus.inProgress;
      case JobStatus.inProgress:
        return JobStatus.completed;
      default:
        return current;
    }
  }

  Map<String, dynamic> _getButtonConfig(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return {'text': 'قبول الطلب', 'icon': Icons.check_circle, 'color': AppTheme.successColor};
      case JobStatus.onWay:
        return {'text': 'في الطريق', 'icon': Icons.navigation, 'color': AppTheme.primaryColor};
      case JobStatus.arrived:
        return {'text': 'وصلت للموقع', 'icon': Icons.location_on, 'color': Colors.cyan};
      case JobStatus.inProgress:
        return {'text': 'بدء العمل', 'icon': Icons.build, 'color': Colors.orange};
      case JobStatus.completed:
        return {'text': 'إنهاء وتحصيل', 'icon': Icons.attach_money, 'color': AppTheme.successColor};
      default:
        return {'text': 'تحديث', 'icon': Icons.refresh, 'color': Colors.grey};
    }
  }

  void _updateJobStatus(TechJob job, JobStatus newStatus) {
    setState(() {
      final index = _jobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _jobs[index] = job.copyWith(status: newStatus);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث حالة الطلب إلى: ${_getStatusConfig(newStatus)['text']}')),
    );
  }
}

// Models
enum JobStatus { pending, accepted, onWay, arrived, inProgress, completed, cancelled }

class TechJob {
  final String id;
  final String clientName;
  final String address;
  final String problemDesc;
  final double price;
  final JobStatus status;
  final DateTime date;
  final String paymentMethod;

  TechJob({
    required this.id,
    required this.clientName,
    required this.address,
    required this.problemDesc,
    required this.price,
    required this.status,
    required this.date,
    required this.paymentMethod,
  });

  TechJob copyWith({
    String? id,
    String? clientName,
    String? address,
    String? problemDesc,
    double? price,
    JobStatus? status,
    DateTime? date,
    String? paymentMethod,
  }) {
    return TechJob(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      address: address ?? this.address,
      problemDesc: problemDesc ?? this.problemDesc,
      price: price ?? this.price,
      status: status ?? this.status,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
