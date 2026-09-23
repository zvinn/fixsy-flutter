import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class TechnicianProfileScreen extends StatefulWidget {

  const TechnicianProfileScreen({
    super.key,
    this.techId = 'tech_01',
    this.techName = 'م. أحمد حسني',
    this.specialty = 'خبير السباكة وتأسيس الشبكات',
    this.area = 'القاهرة - المعادي وحلوان',
    this.rating = 4.9,
    this.completedJobs = 214,
    this.phone = '+201012345678',
    this.isVerified = true,
    this.avatarUrl,
  });
  final String techId;
  final String techName;
  final String specialty;
  final String area;
  final double rating;
  final int completedJobs;
  final String phone;
  final bool isVerified;
  final String? avatarUrl;

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;

  final List<Map<String, dynamic>> _portfolioItems = [
    {
      'title': 'تأسيس شبكة مياه وصرف متكاملة',
      'category': 'سباكة وتشطيبات',
      'date': 'منذ أسبوعين',
      'image': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600',
      'description': 'تركيب مواسير بولي بروبيلين ألماني واختبار الضغط بالبار مع ضمان 10 سنوات.',
    },
    {
      'title': 'كشف تسريبات ومعالجة رطوبة الجدران',
      'category': 'كشف تسريبات',
      'date': 'منذ شهر',
      'image': 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=600',
      'description': 'استخدام أجهزة فحص فوق صوتية بدون تكسير ومعالجة التسريب في الحمام الرئيسي.',
    },
    {
      'title': 'تركيب وصيانة سخانات غاز مركزية',
      'category': 'سخانات وغاز',
      'date': 'منذ شهرين',
      'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
      'description': 'تركيب وتوصيل مدخنة الأمان وصمامات ضغط الغاز ومفاتيح الفصل الأوتوماتيكية.',
    },
    {
      'title': 'تجديد كامل لأطقم وخلاطات الحمام',
      'category': 'إصلاح وتركيب',
      'date': 'منذ 3 أشهر',
      'image': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600',
      'description': 'استبدال المحابس القديمة وتثبيت خلاطات دفن إيطالية مع ضبط ضغط المياه.',
    },
  ];

  final List<Map<String, dynamic>> _reviews = [
    {
      'clientName': 'كريم عبد الرحمن',
      'rating': 5.0,
      'date': 'منذ 3 أيام',
      'comment': 'فني ممتاز جداً وأمين. وصل في الموعد بالضبط وحل مشكلة التسريب في أقل من ساعة وبدون أي فوضى.',
      'service': 'كشف تسريب مياه',
    },
    {
      'clientName': 'مها السيد',
      'rating': 5.0,
      'date': 'منذ أسبوع',
      'comment': 'محترم ومحترف وشغله نظيف جداً. السعر كان عادل مقارنة بجودة الشغل الممتازة.',
      'service': 'تغيير خلاطات ومحابس',
    },
    {
      'clientName': 'د. سامي توفيق',
      'rating': 4.5,
      'date': 'منذ 3 أسابيع',
      'comment': 'مهندس أحمد عنده خبرة واضحة في مجال السباكة الحديثة، أنصح بالتعامل معه.',
      'service': 'صيانة شبكة الصرف',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildProfileHeaderCard(),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'نبذة والشهادات'),
                  Tab(text: 'معرض الأعمال'),
                  Tab(text: 'التقييمات'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(),
            _buildPortfolioTab(),
            _buildReviewsTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyBookingBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.redAccent : Colors.white,
          ),
          onPressed: () {
            setState(() => _isFavorite = !_isFavorite);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isFavorite ? 'تمت إضافة الفني إلى المفضلة' : 'تمت الإزالة من المفضلة'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم نسخ رابط ملف الفني للمشاركة')),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 42, color: AppTheme.primaryColor),
                  ),
                  if (widget.isVerified)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: Colors.blue, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Name & Specialty
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.techName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'متاح الآن',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.specialty,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          widget.area,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('التقييم العام', '${widget.rating} ⭐', Colors.amber.shade800),
                Container(height: 24, width: 1, color: Colors.grey.shade300),
                _buildStatItem('الخدمات المكتملة', '+${widget.completedJobs}', AppTheme.primaryColor),
                Container(height: 24, width: 1, color: Colors.grey.shade300),
                _buildStatItem('سنوات الخبرة', '8 سنوات', AppTheme.successColor),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Action Buttons (Chat & Call)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: {
                        'conversationId': 'conv_${widget.techId}',
                        'otherUserName': widget.techName,
                        'otherUserId': widget.techId,
                      },
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('محادثة الفني'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showCallDialog,
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('اتصال مباشر'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          _buildSectionCard(
            title: 'نبذة عن الفني',
            icon: Icons.person_outline,
            child: Text(
              'فني سباكة معتمد بخبرة تزيد عن 8 سنوات في مجال التأسيس والتشطيب والصيانة المنزلية المتقدمة. متخصص في كشف التسريبات إلكترونياً وصيانة السخانات والمضخات بدقة وضمان معتمد من Fixsy.',
              style: TextStyle(color: Colors.grey.shade800, height: 1.5, fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),

          // Badges & Certifications
          _buildSectionCard(
            title: 'الأوسمة والشهادات المعتمدة',
            icon: Icons.verified_user_outlined,
            child: Column(
              children: [
                _buildBadgeItem(
                  icon: Icons.badge_outlined,
                  title: 'فني موثق بالهوية الوطنية',
                  subtitle: 'تم التحقق من بطاقة الرقم القومي ومحل الإقامة رسمياً',
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                _buildBadgeItem(
                  icon: Icons.security,
                  title: 'فحص جنائي معتمد (فيش جنائي نظيف)',
                  subtitle: 'سجل أمني معتمد وخالٍ من أي سوابق لضمان أمان منزلك',
                  color: Colors.teal,
                ),
                const SizedBox(height: 10),
                _buildBadgeItem(
                  icon: Icons.workspace_premium,
                  title: 'شهادة Fixsy الاحترافية للسلامة',
                  subtitle: 'مجتاز كافة اختبارات الكفاءة الفنية ومعايير الجودة',
                  color: Colors.amber.shade800,
                ),
                const SizedBox(height: 10),
                _buildBadgeItem(
                  icon: Icons.flash_on,
                  title: 'سرعة استجابة فائقة',
                  subtitle: 'متوسط الوصول لموقع العميل أقل من 25 دقيقة',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Skills
          _buildSectionCard(
            title: 'المهارات والتخصصات',
            icon: Icons.handyman_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'تأسيس شبكات الصرف',
                'كشف التسريبات إلكترونياً',
                'صيانة سخانات الغاز',
                'تركيب مواتير المياه',
                'صيانة فلاتر المياه',
                'تركيب خلاطات دفن',
                'عزل أرضيات وحمامات',
                'تسليك بالضغط الهوائي',
              ].map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Work hours
          _buildSectionCard(
            title: 'ساعات العمل والتغطية',
            icon: Icons.access_time,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الأيام المتاحة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('السبت إلى الخميس (خدمات طوارئ الجمعة)', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ساعات العمل:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('8:00 صباحاً - 10:00 مساءً', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _portfolioItems.length,
      itemBuilder: (context, index) {
        final item = _portfolioItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              // Image Preview
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey.shade400),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['category'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Text(
                          item['date'] as String,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['description'] as String,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      '${widget.rating}',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star_half, color: Colors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'بناءً على 134 تقييم',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar('5 نجوم', 0.88),
                      _buildRatingBar('4 نجوم', 0.08),
                      _buildRatingBar('3 نجوم', 0.03),
                      _buildRatingBar('نجمتان', 0.01),
                      _buildRatingBar('نجمة واحدة', 0.00),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'آراء وتقييمات العملاء (${_reviews.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),

          ..._reviews.map((rev) => _buildReviewItem(rev)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                color: Colors.amber,
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> rev) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      (rev['clientName'] as String).substring(0, 1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rev['clientName'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Text(
                rev['date'] as String,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Row(
                children: List.generate(
                  (rev['rating'] as double).toInt(),
                  (_) => const Icon(Icons.star, color: Colors.amber, size: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rev['service'] as String,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rev['comment'] as String,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBadgeItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBookingBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رسوم المعاينة المبدئية', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const Text(
                  '100 ج.م',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.newRequest);
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('طلب حجز مع الفني'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('اتصال بالفني', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal,
              child: Icon(Icons.phone, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 12),
            Text(widget.techName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(widget.phone, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('جاري بدء الاتصال برقم ${widget.phone}...')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('اتصال الآن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {

  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
