import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Job Model
class Job {
  final String id;
  final String title;
  final String description;
  final String serviceType;
  final String location;
  final double distance;
  final double price;
  final DateTime createdAt;
  final String clientName;
  final String? clientPhoto;
  final bool isUrgent;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.location,
    required this.distance,
    required this.price,
    required this.createdAt,
    required this.clientName,
    this.clientPhoto,
    this.isUrgent = false,
  });
}

/// Job Market Screen - Shows available jobs for technicians
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

    // Sample jobs data
    await Future.delayed(const Duration(milliseconds: 500));

    _allJobs = [
      Job(
        id: '1',
        title: 'إصلاح تسريب مياه',
        description: 'يوجد تسريب في أنبوب المياه أسفل المغسلة في المطبخ',
        serviceType: 'سباكة',
        location: 'المعادي، القاهرة',
        distance: 2.5,
        price: 150,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        clientName: 'أحمد محمد',
        isUrgent: true,
      ),
      Job(
        id: '2',
        title: 'تركيب نجفة',
        description: 'تركيب نجفة جديدة في غرفة المعيشة مع توصيل الأسلاك',
        serviceType: 'كهرباء',
        location: 'مدينة نصر، القاهرة',
        distance: 4.2,
        price: 200,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        clientName: 'سارة علي',
      ),
      Job(
        id: '3',
        title: 'إصلاح باب خشبي',
        description: 'باب غرفة النوم لا يغلق بشكل صحيح',
        serviceType: 'نجارة',
        location: 'الدقي، الجيزة',
        distance: 5.8,
        price: 120,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        clientName: 'محمود حسن',
      ),
      Job(
        id: '4',
        title: 'صيانة مكيف سبليت',
        description: 'المكيف لا يبرد بشكل كافي ويصدر صوتاً',
        serviceType: 'تكييف',
        location: 'التجمع الخامس، القاهرة',
        distance: 8.1,
        price: 250,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        clientName: 'هاني عبدالله',
        isUrgent: true,
      ),
    ];

    _nearbyJobs = _allJobs.where((j) => j.distance <= 5).toList();
    _urgentJobs = _allJobs.where((j) => j.isUrgent).toList();

    setState(() => _isLoading = false);
  }

  List<Job> _getFilteredJobs(List<Job> jobs) {
    if (_selectedFilter == 'الكل') return jobs;
    return jobs.where((j) => j.serviceType == _selectedFilter).toList();
  }

  void _acceptJob(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قبول الطلب'),
        content: Text('هل تريد قبول طلب "${job.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم قبول الطلب! سيتم التواصل معك قريباً'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('قبول'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          title: const Text('سوق العمل'),
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
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Jobs List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildJobsList(_getFilteredJobs(_allJobs), isDark),
                        _buildJobsList(_getFilteredJobs(_nearbyJobs), isDark),
                        _buildJobsList(_getFilteredJobs(_urgentJobs), isDark),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(List<Job> jobs, bool isDark) {
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
              'لا توجد طلبات متاحة',
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
            onAccept: () => _acceptJob(job),
          ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final bool isDark;
  final VoidCallback onAccept;

  const _JobCard({
    required this.job,
    required this.isDark,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: job.isUrgent
              ? Colors.red.withOpacity(0.5)
              : (isDark ? Colors.white12 : Colors.grey.shade200),
          width: job.isUrgent ? 2 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                // Service Type Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getServiceColor(job.serviceType).withOpacity(0.1),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'عاجل',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
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

          // Info Row
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
                Text(
                  '${job.price.toInt()} ج.م',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Client Info & Accept Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    job.clientName[0],
                    style: TextStyle(
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
                ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('قبول'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

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
