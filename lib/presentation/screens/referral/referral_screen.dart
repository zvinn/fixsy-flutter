import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';

/// Referral Service - Handles referral code generation and validation
class ReferralService {
  /// Generate a unique referral code based on user ID
  static String generateCode(String userId) {
    final prefix = 'FIXSY';
    final suffix = userId.substring(0, 4).toUpperCase();
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return '$prefix$suffix$random';
  }

  /// Validate referral code format
  static bool isValidCode(String code) {
    return code.startsWith('FIXSY') && code.length >= 10;
  }
}

/// Referral Screen - Shows user's referral code and stats
class ReferralScreen extends StatefulWidget {
  final String userId;
  final String? referralCode;
  final int referralCount;
  final double earnedRewards;

  const ReferralScreen({
    super.key,
    required this.userId,
    this.referralCode,
    this.referralCount = 0,
    this.earnedRewards = 0,
  });

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  late String _referralCode;
  final TextEditingController _codeController = TextEditingController();
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _referralCode = widget.referralCode ?? 
        ReferralService.generateCode(widget.userId);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _referralCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الكود!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _shareCode() async {
    await Share.share(
      'استخدم كود الدعوة الخاص بي في تطبيق Fixsy واحصل على خصم!\n\nالكود: $_referralCode\n\nحمل التطبيق الآن!',
    );
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    if (!ReferralService.isValidCode(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كود غير صالح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (code == _referralCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكنك استخدام كودك الخاص'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isApplying = true);

    try {
      // TODO: Validate with backend
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تطبيق الكود بنجاح! حصلت على خصم 10%'),
          backgroundColor: Colors.green,
        ),
      );
      _codeController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ، حاول مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
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
          title: const Text('دعوة أصدقاء'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Referral Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ادعُ أصدقائك واكسب!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'احصل على 20 ج.م عن كل صديق يسجل باستخدام كودك',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Your Code Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كود الدعوة الخاص بك',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _referralCode,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _copyCode,
                            icon: Icon(
                              Icons.copy,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _shareCode,
                        icon: const Icon(Icons.share),
                        label: const Text('مشاركة الكود'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      icon: Icons.people,
                      label: 'الدعوات',
                      value: '${widget.referralCount}',
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatBox(
                      icon: Icons.wallet,
                      label: 'الأرباح',
                      value: '${widget.earnedRewards.toInt()} ج.م',
                      color: Colors.green,
                      isDark: isDark,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Apply Code Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'هل لديك كود دعوة؟',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'أدخل كود الدعوة',
                              filled: true,
                              fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isApplying ? null : _applyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isApplying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('تطبيق'),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // How it works
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كيف يعمل البرنامج؟',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StepItem(
                      number: 1,
                      text: 'شارك كود الدعوة مع أصدقائك',
                      isDark: isDark,
                    ),
                    _StepItem(
                      number: 2,
                      text: 'صديقك يسجل باستخدام الكود',
                      isDark: isDark,
                    ),
                    _StepItem(
                      number: 3,
                      text: 'تحصل على 20 ج.م في محفظتك',
                      isDark: isDark,
                    ),
                    _StepItem(
                      number: 4,
                      text: 'صديقك يحصل على خصم 10%',
                      isDark: isDark,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatBox({
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final String text;
  final bool isDark;

  const _StepItem({
    required this.number,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
