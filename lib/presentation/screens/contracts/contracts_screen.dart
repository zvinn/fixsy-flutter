import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen({super.key});

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  String? _activeContractTitle;

  void _subscribe(String title, String price, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.verified_user_outlined, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تأكيد الاشتراك: $title',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$price ج.م / سنوياً',
                      style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'طريقة الدفع:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('المحفظة الإلكترونية (رصيد متاح)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Icon(Icons.check_circle, color: AppTheme.primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _activeContractTitle = title);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 تهانينا! تم تفعيل $title لمنزلك بنجاح.'),
                      backgroundColor: AppTheme.successColor,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('تأكيد الاشتراك وتفعيل الباقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عقود الصيانة السنوية'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_activeContractTitle != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('عقد الصيانة نشط حالياً', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                          Text('أنت مشترك الآن في: $_activeContractTitle', style: const TextStyle(fontSize: 12, color: Color(0xFF047857))),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),
            ],

            const Text(
              'اختر الباقة المناسبة لمنزلك',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 8),
            
            Text(
              'راحة بال وحماية لأجهزتك ومرافق منزلك طوال العام',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            
            const SizedBox(height: 32),

            _buildContractCard(
              context,
              title: 'الباقة الذهبية',
              price: '3000',
              color: Colors.amber.shade800,
              features: [
                '6 زيارات صيانة وقائية مجدولة',
                'زيارات طارئة غير محدودة طوال العام',
                'خصم 20% على جميع قطع الغيار الأصلية',
                'أولوية قصوى في الحجز والمواعيد',
                'فحص دوري لشبكات الكهرباء والسباكة والتكييف',
              ],
              isRecommended: true,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            _buildContractCard(
              context,
              title: 'الباقة الفضية',
              price: '1500',
              color: Colors.blueGrey,
              features: [
                '3 زيارات صيانة وقائية',
                '5 زيارات طارئة مجانية',
                'خصم 10% على قطع الغيار',
                'استجابة فورية خلال 24 ساعة',
              ],
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            _buildContractCard(
              context,
              title: 'الباقة البرونزية',
              price: '800',
              color: Colors.brown.shade400,
              features: [
                'زيارة صيانة وقائية واحدة شاملة',
                'فحص شامل لكافة أجهزة ومرافق المنزل',
                'خصم 5% على قطع الغيار',
              ],
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildContractCard(
    BuildContext context, {
    required String title,
    required String price,
    required Color color,
    required List<String> features,
    bool isRecommended = false,
  }) {
    final isCurrentActive = _activeContractTitle == title;

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrentActive ? const Color(0xFF10B981) : (isRecommended ? color : Colors.grey.shade200),
              width: (isRecommended || isCurrentActive) ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: color),
                        children: [
                          TextSpan(
                            text: price,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: ' ج.م / سنة',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Features
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
              
              const SizedBox(height: 24),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: isCurrentActive ? null : () => _subscribe(title, price, color),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentActive ? const Color(0xFF10B981) : color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isCurrentActive ? 'باقة منزلك النشطة حالياً' : 'اشترك الآن',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isRecommended && !isCurrentActive)
          Positioned(
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: const Text(
                'الأكثر مبيعاً',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
