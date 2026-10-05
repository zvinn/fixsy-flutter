import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      badge: 'خدمة فورية وبأعلى جودة ⚡',
      badgeColor: const Color(0xFFF59E0B),
      title: 'صيانتك في وقتها وبأعلى دقة',
      description: 'اطلب فني متخصص بضغطة زر واحدة، نصلك في الموعد المحدد مع أدوات متكاملة وخبرة مضمونة لراحة بالك.',
      icon: LucideIcons.wrench,
      gradientColors: const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
      feature1: 'استجابة سريعة ⏱️',
      feature2: 'فني معتمد 🏅',
    ),
    OnboardingItem(
      badge: 'أمان وموثوقية 100% 🛡️',
      badgeColor: const Color(0xFF10B981),
      title: 'فنيون محترفون ومفحوصون',
      description: 'جميع الفنيين يخضعون لفحص هوية وسجل أمني وتدريب عالي لضمان سلامة منزلك وأعلى جودة في التنفيذ.',
      icon: LucideIcons.shieldCheck,
      gradientColors: const [Color(0xFF0F766E), Color(0xFF10B981)],
      feature1: 'فحص أمني دقيق ✅',
      feature2: 'ضمان 30 يوم 🌟',
    ),
    OnboardingItem(
      badge: 'شفافية وضمان معتمد 💎',
      badgeColor: const Color(0xFFFF6B00),
      title: 'تسعير شفاف ودفع ذكي آمن',
      description: 'تعرف على التكلفة المقدرة قبل البدء بدون أي رسوم خفية، مع دعم كامل لخيارات الدفع الإلكتروني والتقسيط.',
      icon: LucideIcons.sparkles,
      gradientColors: const [Color(0xFFFF6B00), Color(0xFFFF9500)],
      feature1: 'تسعير مسبق عادل 💵',
      feature2: 'دفع إلكتروني آمن 🔒',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _items.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // Decorative background glowing ambient gradients
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryLight.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondaryColor.withOpacity(0.07),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top Header Bar: Brand + Skip Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // App Brand Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withOpacity(0.12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                  ),
                                ),
                                child: const Icon(LucideIcons.wrench, size: 11, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Fixsy • فيكسي',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Skip Button
                        if (!isLastPage)
                          TextButton(
                            onPressed: _completeOnboarding,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey.withOpacity(0.12)),
                              ),
                            ),
                            child: Text(
                              'تخطي',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 60),
                      ],
                    ),
                  ),

                  // Carousel Page View
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return _OnboardingPageView(item: _items[index]);
                      },
                    ),
                  ),

                  // Bottom Controls (Pill Indicators + Gradient CTA Button)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Animated Indicators
                        Row(
                          children: List.generate(
                            _items.length,
                            (index) {
                              final isCurrent = _currentPage == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isCurrent ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: isCurrent
                                      ? const LinearGradient(
                                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                        )
                                      : null,
                                  color: isCurrent ? null : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            },
                          ),
                        ),

                        // Next / Start Button
                        InkWell(
                          onTap: _nextPage,
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(
                              horizontal: isLastPage ? 28 : 22,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isLastPage
                                    ? [const Color(0xFFFF6B00), const Color(0xFFFF8533)]
                                    : [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isLastPage
                                          ? const Color(0xFFFF6B00)
                                          : const Color(0xFF1E3A8A))
                                      .withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isLastPage ? 'ابدأ الآن' : 'التالي',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLastPage ? LucideIcons.rocket : LucideIcons.arrowLeft,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  OnboardingItem({
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.feature1,
    required this.feature2,
  });

  final String badge;
  final Color badgeColor;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String feature1;
  final String feature2;
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Badge with Glowing Layers & Floating Pills
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer subtle glowing aura ring
                Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.gradientColors.first.withOpacity(0.06),
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),

                // Middle glowing circle
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.gradientColors.first.withOpacity(0.12),
                  ),
                ),

                // Main Core Glowing Icon Container
                Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.gradientColors.first.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                // Floating Feature Pill 1 (Top Left)
                Positioned(
                  top: 20,
                  left: 10,
                  child: _FloatingFeatureBadge(text: item.feature1)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideX(begin: -0.3, end: 0),
                ),

                // Floating Feature Pill 2 (Bottom Right)
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: _FloatingFeatureBadge(text: item.feature2)
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .slideX(begin: 0.3, end: 0),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Category Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: item.badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.badgeColor.withOpacity(0.25)),
            ),
            child: Text(
              item.badge,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: item.badgeColor,
              ),
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 18),

          // Main Title
          Text(
            item.title,
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 14),

          // Detailed Subtitle
          Text(
            item.description,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryLight,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _FloatingFeatureBadge extends StatelessWidget {
  const _FloatingFeatureBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimaryLight,
        ),
      ),
    );
  }
}
