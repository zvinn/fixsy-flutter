import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// TechOnboarding - Onboarding flow for new technicians
class TechOnboardingScreen extends StatefulWidget {
  const TechOnboardingScreen({super.key});

  @override
  State<TechOnboardingScreen> createState() => _TechOnboardingScreenState();
}

class _TechOnboardingScreenState extends State<TechOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'مرحباً بك في Fixsy',
      description: 'انضم لأكبر شبكة فنيين محترفين في مصر واحصل على طلبات عمل يومية',
      icon: Icons.handshake,
      color: AppTheme.primaryColor,
    ),
    OnboardingStep(
      title: 'استلم الطلبات',
      description: 'سيصلك إشعار فوري عند وجود طلب جديد قريب منك. يمكنك قبول أو رفض الطلب',
      icon: Icons.notifications_active,
      color: Colors.orange,
    ),
    OnboardingStep(
      title: 'تتبع موقعك',
      description: 'العميل سيتمكن من تتبع موقعك للوصول إليه. تأكد من تفعيل GPS',
      icon: Icons.location_on,
      color: Colors.blue,
    ),
    OnboardingStep(
      title: 'احصل على تقييمك',
      description: 'بعد كل خدمة، سيقوم العميل بتقييمك. التقييم العالي يجلب المزيد من الطلبات',
      icon: Icons.star,
      color: Colors.amber,
    ),
    OnboardingStep(
      title: 'اسحب أرباحك',
      description: 'يمكنك سحب أرباحك في أي وقت عبر المحفظة الإلكترونية أو التحويل البنكي',
      icon: Icons.account_balance_wallet,
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // TODO: Save onboarding completion to local storage
    Navigator.pushReplacementNamed(context, '/tech-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return _OnboardingPage(
                      step: step,
                      isDark: isDark,
                    );
                  },
                ),
              ),

              // Page Indicator & Next Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.primaryColor
                                : (isDark ? Colors.white24 : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage == _steps.length - 1 ? 'ابدأ الآن' : 'التالي',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingStep step;
  final bool isDark;

  const _OnboardingPage({
    required this.step,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: step.color,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 48),

          // Title
          Text(
            step.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
