import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/enhanced_widgets.dart';
import '../../widgets/stories/stories_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/services/weather_service.dart';
import '../../widgets/ai/voice_assistant_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  WeatherAlert? _weatherAlert;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _headerController.forward();
    _cardsController.forward();

    _checkWeather();
  }

  Future<void> _checkWeather() async {
    final alert = await WeatherService().checkWeatherAlerts(31.0, 31.0);
    if (mounted && alert != null) {
      setState(() => _weatherAlert = alert);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${context.t('hello')}، ${user?.displayName ?? context.t('client')}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 4),
                      Text(
                        context.t('howCanWeHelp'),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Voice Assistant Trigger
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.mic, color: AppTheme.primaryColor),
                  tooltip: 'المساعد الصوتي',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const VoiceAssistantSheet(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              
              IconButton(
                icon: const Icon(Icons.groups_outlined, color: AppTheme.textPrimaryColor),
                onPressed: () => Navigator.pushNamed(context, '/community'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textPrimaryColor),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
               IconButton(
                icon: const Icon(Icons.person_outline_rounded, color: AppTheme.textPrimaryColor),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_weatherAlert != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _weatherAlert!.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                                ),
                                Text(
                                  _weatherAlert!.description,
                                  style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                  ),

                const SizedBox(height: 8),
                
                const StoriesWidget(userRole: 'client').animate().fadeIn(delay: 100.ms),
                
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SectionHeader(
                    title: context.t('availableServices'),
                    subtitle: context.t('selectService'),
                    onSeeAll: () => Navigator.pushNamed(context, '/services'),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      EnhancedServiceCard(
                        icon: Icons.plumbing,
                        title: context.t('plumbing'),
                        subtitle: context.t('available24_7'),
                        gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        onTap: () => _navigateToService('plumbing'),
                      ).animate().scale(delay: 300.ms, duration: 400.ms).fadeIn(),
                      
                      EnhancedServiceCard(
                        icon: Icons.electrical_services,
                        title: context.t('electrical'),
                        subtitle: context.t('fastService'),
                        gradientColors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                        onTap: () => _navigateToService('electrical'),
                      ).animate().scale(delay: 400.ms, duration: 400.ms).fadeIn(),
                      
                      EnhancedServiceCard(
                        icon: Icons.carpenter,
                        title: context.t('carpentry'),
                        subtitle: context.t('highQuality'),
                        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        onTap: () => _navigateToService('carpentry'),
                      ).animate().scale(delay: 500.ms, duration: 400.ms).fadeIn(),
                      
                      EnhancedServiceCard(
                        icon: Icons.format_paint,
                        title: context.t('painting'),
                        subtitle: context.t('varietyColors'),
                        gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                        onTap: () => _navigateToService('painting'),
                      ).animate().scale(delay: 600.ms, duration: 400.ms).fadeIn(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // NEW: Featured Section (Store & Contracts)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'اكتشف المزيد',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildFeaturedCard(
                        context,
                        title: 'متجر Fixsy',
                        subtitle: 'قطع غيار أصلية',
                        icon: Icons.storefront,
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, '/store'),
                      ),
                      const SizedBox(width: 16),
                      _buildFeaturedCard(
                        context,
                        title: 'عقود الصيانة',
                        subtitle: 'راحة بال سنوية',
                        icon: Icons.verified_user_outlined,
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/contracts'),
                      ),
                      const SizedBox(width: 16),
                      _buildFeaturedCard(
                        context,
                        title: 'برنامج الولاء',
                        subtitle: 'نقاط ومكافآت',
                        icon: Icons.stars,
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(context, '/loyalty'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    context.t('quickStats'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: context.t('bookings'),
                          value: '0',
                          icon: Icons.calendar_today,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: context.t('completed'),
                          value: '0',
                          icon: Icons.check_circle,
                          color: AppTheme.successColor,
                          trend: '+0%',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SectionHeader(
                    title: context.t('recentBookings'),
                    onSeeAll: () => Navigator.pushNamed(context, '/bookings'),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: EmptyStateWidget(
                    icon: Icons.inbox_outlined,
                    title: context.t('noBookingsYet'),
                    subtitle: context.t('startBooking'),
                    buttonText: context.t('requestService'),
                    onButtonPressed: () => Navigator.pushNamed(context, '/new-request'),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/new-request'),
        icon: const Icon(Icons.add),
        label: Text(context.t('newRequest')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  Widget _buildFeaturedCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToService(String serviceId) {
    Navigator.pushNamed(context, '/new-request', arguments: serviceId);
  }
}
