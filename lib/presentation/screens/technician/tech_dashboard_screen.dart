import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/tech_dashboard_provider.dart';
import '../../providers/auth_provider.dart';

class TechDashboardScreen extends StatefulWidget {
  const TechDashboardScreen({super.key});

  @override
  State<TechDashboardScreen> createState() => _TechDashboardScreenState();
}

class _TechDashboardScreenState extends State<TechDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showEarningsChart = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final auth = Provider.of<AuthProvider?>(context, listen: false);
        final techProvider = Provider.of<TechDashboardProvider?>(context, listen: false);
        final email = auth?.currentUser?.email;
        if (email != null && email.isNotEmpty) {
          techProvider?.initTech(email);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final techProvider = Provider.of<TechDashboardProvider?>(context);
    final activeJobs = techProvider?.activeJobs ?? [];
    final historyJobs = techProvider?.historyJobs ?? [];
    final isAvailable = techProvider?.isAvailable ?? true;
    final earnings = techProvider?.earnings ?? 2450.0;
    final walletBalance = techProvider?.walletBalance ?? 1200.0;
    final debt = techProvider?.debt ?? 50.0;
    final isVerified = techProvider?.isVerified ?? true;
    final specialty = techProvider?.specialty ?? 'تكييف وتبريد';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_circle, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text(
              'لوحة تحكم الفني',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Availability Toggle
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Text(
                  isAvailable ? 'متاح' : 'مشغول',
                  style: TextStyle(
                    color: isAvailable ? AppTheme.successColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: (val) {
                    if (techProvider != null) {
                      techProvider.setAvailability(val);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? 'أنت الآن متاح لاستقبال الطلبات الفورية' : 'تم تغيير حالتك إلى غير متاح'),
                      ),
                    );
                  },
                  // ignore: deprecated_member_use
                  activeColor: AppTheme.successColor,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Technician Info Header Banner
            _buildTechProfileHeader(isVerified, specialty, techProvider),

            // Debt Warning Alert (If debt exceeds limit 200 EGP)
            if (debt >= 200) _buildDebtAlertBanner(debt),

            // Financial Summary Card & Chart
            _buildStatsAndChartCard(earnings, walletBalance, debt, techProvider),

            const SizedBox(height: 12),

            // Tabs Header
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: [
                  Tab(text: '🚀 الطلبات النشطة (${activeJobs.length})'),
                  Tab(text: '📜 سجل الطلبات (${historyJobs.length})'),
                ],
              ),
            ),

            // Tab Content
            SizedBox(
              height: 520,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobsList(activeJobs, isHistory: false, provider: techProvider),
                  _buildJobsList(historyJobs, isHistory: true, provider: techProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE & SCHEDULE HEADER
  // ---------------------------------------------------------------------------
  Widget _buildTechProfileHeader(bool isVerified, String specialty, TechDashboardProvider? provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.person, color: AppTheme.primaryColor, size: 30),
              ),
              if (isVerified)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.verified, color: AppTheme.successColor, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'م. كريم سامي',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'فني معتمد',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'التخصص: $specialty • تقييم 4.9 ★',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          // Schedule button
          OutlinedButton.icon(
            onPressed: () => _showScheduleModal(provider),
            icon: const Icon(Icons.schedule, size: 16),
            label: const Text('جدول العمل', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DEBT ALERT BANNER
  // ---------------------------------------------------------------------------
  Widget _buildDebtAlertBanner(double debt) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تنبيه: تجاوزت حد مديونية المنصة',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'المبلغ المستحق: ${debt.toStringAsFixed(0)} ج.م. يرجى سداد عمولة المنصة لتجنب إيقاف استقبال الطلبات.',
                  style: TextStyle(color: Colors.red.shade800, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/wallet'),
            child: const Text('سداد الآن', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATS & 7-DAY EARNINGS CHART
  // ---------------------------------------------------------------------------
  Widget _buildStatsAndChartCard(
    double earnings,
    double walletBalance,
    double debt,
    TechDashboardProvider? provider,
  ) {
    final spots = provider?.getEarningsChartSpots() ?? const [
      FlSpot(0, 350),
      FlSpot(1, 550),
      FlSpot(2, 400),
      FlSpot(3, 750),
      FlSpot(4, 900),
      FlSpot(5, 650),
      FlSpot(6, 1200),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stat Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('الأرباح الكلية', '${earnings.toStringAsFixed(0)} ج.م', Colors.white),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildStatItem('رصيد المحفظة', '${walletBalance.toStringAsFixed(0)} ج.م', Colors.amber),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildStatItem('المستحق للمنصة', '${debt.toStringAsFixed(0)} ج.م', debt >= 200 ? Colors.redAccent : Colors.white70),
            ],
          ),
          const Divider(height: 28, color: Colors.white24),

          // Chart Toggle Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'أرباح آخر 7 أيام',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() => _showEarningsChart = !_showEarningsChart);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        _showEarningsChart ? 'إخفاء' : 'عرض الرسم',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Icon(
                        _showEarningsChart ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Chart
          if (_showEarningsChart) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
                          final idx = value.toInt();
                          if (idx >= 0 && idx < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(days[idx], style: const TextStyle(color: Colors.white60, fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: const Color(0xFF10B981),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 3,
                          color: const Color(0xFF10B981),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // JOB LIST & CARDS
  // ---------------------------------------------------------------------------
  Widget _buildJobsList(List<TechJobModel> jobs, {required bool isHistory, TechDashboardProvider? provider}) {
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
              child: Icon(Icons.assignment_outlined, size: 44, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              isHistory ? 'لا توجد طلبات سابقة في السجل' : 'لا توجد طلبات نشطة حالياً',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _buildJobCard(jobs[index], provider),
    );
  }

  Widget _buildJobCard(TechJobModel job, TechDashboardProvider? provider) {
    final nextStatus = provider?.getNextStatus(job.status) ?? TechJobStatus.accepted;
    final isCompleted = job.status == TechJobStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client Header + Payment badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      job.clientName.isNotEmpty ? job.clientName[0] : 'U',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.clientName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        job.scheduledDate ?? 'اليوم',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusChip(job.status),
            ],
          ),
          const SizedBox(height: 14),

          // Problem Description Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.handyman_outlined, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.problemDesc,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job.address,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الأجر المتفق عليه:', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    Text(
                      '${job.price.toStringAsFixed(0)} ج.م',
                      style: const TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Action Tools: Call Client & Chat
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final phone = job.clientPhone ?? '01000000000';
                    launchUrl(Uri.parse('tel:$phone'));
                  },
                  icon: const Icon(Icons.call, size: 16, color: AppTheme.primaryColor),
                  label: const Text('اتصال'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF0F172A)),
                  label: const Text('محادثة', style: TextStyle(color: Color(0xFF0F172A))),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Step-by-Step Flow Button
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => _handleStatusStep(job, nextStatus, provider),
                icon: Icon(_getStatusButtonIcon(nextStatus), size: 18),
                label: Text(_getStatusButtonLabel(nextStatus)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStatusButtonColor(nextStatus),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppTheme.successColor, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'تم إنجاز الطلب بنجاح واستلام المبلغ 🎉',
                    style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleStatusStep(TechJobModel job, TechJobStatus nextStatus, TechDashboardProvider? provider) {
    if (provider != null) {
      provider.updateJobStatus(job.id, nextStatus);
    }

    if (nextStatus == TechJobStatus.completed) {
      _showCompletionCelebrationDialog(job);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primaryColor,
          content: Text('تم تحديث حالة الطلب إلى: ${nextStatus.labelArabic} 🚀'),
        ),
      );
    }
  }

  void _showCompletionCelebrationDialog(TechJobModel job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFDCFCE7),
              child: Icon(Icons.verified, color: AppTheme.successColor, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'أحسنت صنعاً! 🎉',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'تم إكمال المهمة وإضافة ${job.price.toStringAsFixed(0)} ج.م إلى أرباحك بنجاح!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('متابعة المهام', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleModal(TechDashboardProvider? provider) {
    final start = provider?.workStartTime ?? '09:00';
    final end = provider?.workEndTime ?? '21:00';
    final offDays = List<String>.from(provider?.offDays ?? ['Friday']);

    final days = [
      {'en': 'Saturday', 'ar': 'السبت'},
      {'en': 'Sunday', 'ar': 'الأحد'},
      {'en': 'Monday', 'ar': 'الإثنين'},
      {'en': 'Tuesday', 'ar': 'الثلاثاء'},
      {'en': 'Wednesday', 'ar': 'الأربعاء'},
      {'en': 'Thursday', 'ar': 'الخميس'},
      {'en': 'Friday', 'ar': 'الجمعة'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'إعدادات أوقات العمل وجدول الإجازات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('بداية الدوام', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(start, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('نهاية الدوام', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text(end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('أيام الإجازة الأسبوعية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: days.map((d) {
                  final isSelected = offDays.contains(d['en']);
                  return FilterChip(
                    label: Text(d['ar']!),
                    selected: isSelected,
                    onSelected: (val) {
                      setModalState(() {
                        if (val) {
                          offDays.add(d['en']!);
                        } else {
                          offDays.remove(d['en']!);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (provider != null) {
                      provider.updateSchedule(start: start, end: end, offDays: offDays);
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ مواعيد العمل بنجاح!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('حفظ الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TechJobStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case TechJobStatus.pending:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade800;
        break;
      case TechJobStatus.accepted:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case TechJobStatus.onWay:
        bg = Colors.cyan.shade50;
        fg = Colors.cyan.shade800;
        break;
      case TechJobStatus.arrived:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade800;
        break;
      case TechJobStatus.inProgress:
        bg = Colors.indigo.shade50;
        fg = Colors.indigo.shade800;
        break;
      case TechJobStatus.completed:
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case TechJobStatus.cancelled:
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status.labelArabic,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  IconData _getStatusButtonIcon(TechJobStatus next) {
    switch (next) {
      case TechJobStatus.accepted:
        return Icons.check_circle_outline;
      case TechJobStatus.onWay:
        return Icons.directions_car_outlined;
      case TechJobStatus.arrived:
        return Icons.location_on_outlined;
      case TechJobStatus.inProgress:
        return Icons.build_outlined;
      case TechJobStatus.completed:
        return Icons.done_all;
      default:
        return Icons.arrow_forward;
    }
  }

  String _getStatusButtonLabel(TechJobStatus next) {
    switch (next) {
      case TechJobStatus.accepted:
        return 'قبول الطلب والتوجه للعميل';
      case TechJobStatus.onWay:
        return 'أنا في الطريق للعميل الآن 🚗';
      case TechJobStatus.arrived:
        return 'وصلت إلى عنوان العميل 📍';
      case TechJobStatus.inProgress:
        return 'بدء أعمال الصيانة والفحص 🔧';
      case TechJobStatus.completed:
        return 'إنهاء الطلب وتحصيل الحساب 🎉';
      default:
        return 'تحديث الحالة';
    }
  }

  Color _getStatusButtonColor(TechJobStatus next) {
    switch (next) {
      case TechJobStatus.accepted:
        return const Color(0xFF0056D2);
      case TechJobStatus.onWay:
        return const Color(0xFF0284C7);
      case TechJobStatus.arrived:
        return const Color(0xFF7C3AED);
      case TechJobStatus.inProgress:
        return const Color(0xFFD97706);
      case TechJobStatus.completed:
        return AppTheme.successColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}
