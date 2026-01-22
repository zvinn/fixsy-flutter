import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

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
      title: 'صيانتك في وقتها',
      description: 'اطلب فني متخصص بضغطة زر، واحصل على خدمة سريعة وموثوقة.',
      icon: Icons.timer_outlined,
      color: Colors.blue,
    ),
    OnboardingItem(
      title: 'فنيين محترفين',
      description: 'جميع الفنيين تم التحقق من هويتهم وكفاءتهم لضمان جودة العمل.',
      icon: Icons.verified_user_outlined,
      color: Colors.green,
    ),
    OnboardingItem(
      title: 'أسعار شفافة',
      description: 'احصل على تسعير تقريبي قبل البدء، وادفع بطريقة آمنة.',
      icon: Icons.payments_outlined,
      color: Colors.orange,
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'تخطي',
                  style: TextStyle(color: AppTheme.textSecondaryLight),
                ),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    item: _items[index],
                  );
                },
              ),
            ),
            
            // Indicators & Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next / Start Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _items.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Icon(
                      _currentPage == _items.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
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
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const _OnboardingPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 100,
              color: item.color,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 48),
          
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
