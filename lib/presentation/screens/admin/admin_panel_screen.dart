import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

/// AdminPanel Screen - Dashboard for platform management
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Sample statistics
  final Map<String, dynamic> _stats = {
    'totalUsers': 1250,
    'totalTechnicians': 85,
    'totalBookings': 3420,
    'activeBookings': 42,
    'revenue': 125000,
    'pendingApprovals': 8,
  };

  final List<Map<String, dynamic>> _recentBookings = [
    {
      'id': 'B001',
      'client': 'أحمد محمد',
      'technician': 'محمد علي',
      'service': 'تكييف',
      'status': 'completed',
      'date': '19/01/2026',
    },
    {
      'id': 'B002',
      'client': 'سارة أحمد',
      'technician': 'علي حسن',
      'service': 'سباكة',
      'status': 'in_progress',
      'date': '19/01/2026',
    },
    {
      'id': 'B003',
      'client': 'محمد سعيد',
      'technician': 'عمر خالد',
      'service': 'كهرباء',
      'status': 'pending',
      'date': '18/01/2026',
    },
  ];

  final List<Map<String, dynamic>> _pendingTechnicians = [
    {
      'id': 'T001',
      'name': 'كريم محمود',
      'specialty': 'تكييف',
      'experience': '5 سنوات',
      'rating': 4.8,
    },
    {
      'id': 'T002',
      'name': 'أيمن سمير',
      'specialty': 'سباكة',
      'experience': '3 سنوات',
      'rating': 4.5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          title: const Text('لوحة التحكم'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Badge(
                label: Text('${_stats['pendingApprovals']}'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            tabs: const [
              Tab(text: 'نظرة عامة'),
              Tab(text: 'الطلبات'),
              Tab(text: 'الفنيين'),
              Tab(text: 'المستخدمين'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(isDark),
                  _buildBookingsTab(isDark),
                  _buildTechniciansTab(isDark),
                  _buildUsersTab(isDark),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.people,
                label: 'المستخدمين',
                value: '${_stats['totalUsers']}',
                color: Colors.blue,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.engineering,
                label: 'الفنيين',
                value: '${_stats['totalTechnicians']}',
                color: Colors.orange,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.receipt_long,
                label: 'إجمالي الطلبات',
                value: '${_stats['totalBookings']}',
                color: Colors.green,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.attach_money,
                label: 'الإيرادات',
                value: '${_stats['revenue']} ج.م',
                color: Colors.purple,
                isDark: isDark,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 24),
          
          // Chart
          Text(
            'إحصائيات الأسبوع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            child: BarChart(
              BarChartData(
                barGroups: [
                  _makeBarGroup(0, 20, 15),
                  _makeBarGroup(1, 25, 18),
                  _makeBarGroup(2, 30, 22),
                  _makeBarGroup(3, 28, 20),
                  _makeBarGroup(4, 35, 25),
                  _makeBarGroup(5, 40, 30),
                  _makeBarGroup(6, 32, 24),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['س', 'أ', 'إ', 'ث', 'أ', 'خ', 'ج'];
                        return Text(
                          days[value.toInt()],
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          
          const SizedBox(height: 24),
          
          // Pending Approvals
          if (_pendingTechnicians.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلبات انضمام الفنيين',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(2),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._pendingTechnicians.map((tech) => _buildPendingTechCard(tech, isDark)),
          ],
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppTheme.primaryColor,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: AppTheme.primaryColor.withOpacity(0.4),
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTechCard(Map<String, dynamic> tech, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              (tech['name'] as String)[0],
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tech['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${tech['specialty']} • ${tech['experience']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _approveTehnician(tech),
                icon: const Icon(Icons.check_circle, color: Colors.green),
              ),
              IconButton(
                onPressed: () => _rejectTechnician(tech),
                icon: const Icon(Icons.cancel, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildBookingsTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentBookings.length,
      itemBuilder: (context, index) {
        final booking = _recentBookings[index];
        return _buildBookingCard(booking, isDark, index);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isDark, int index) {
    Color statusColor;
    String statusText;
    
    switch (booking['status']) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'مكتمل';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = 'جاري';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'معلق';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${booking['id']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: isDark ? Colors.white54 : Colors.black54),
              const SizedBox(width: 6),
              Text(
                'العميل: ${booking['client']}',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.engineering, size: 16, color: isDark ? Colors.white54 : Colors.black54),
              const SizedBox(width: 6),
              Text(
                'الفني: ${booking['technician']}',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.build, size: 16, color: isDark ? Colors.white54 : Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    booking['service'],
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  ),
                ],
              ),
              Text(
                booking['date'],
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms);
  }

  Widget _buildTechniciansTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.engineering,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'إدارة الفنيين',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'إدارة المستخدمين',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _approveTehnician(Map<String, dynamic> tech) {
    setState(() {
      _pendingTechnicians.remove(tech);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم قبول ${tech['name']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectTechnician(Map<String, dynamic> tech) {
    setState(() {
      _pendingTechnicians.remove(tech);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفض ${tech['name']}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
