import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

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
            const Text(
              'اختر الباقة المناسبة لمنزلك',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 8),
            
            Text(
              'راحة بال وحماية لأجهزتك طوال العام',
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
              color: Colors.amber.shade700,
              features: [
                '6 زيارات صيانة وقائية',
                'زيارات طارئة غير محدودة',
                'خصم 20% على قطع الغيار',
                'أولوية قصوى في المواعيد',
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
                'استجابة خلال 24 ساعة',
              ],
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),

            const SizedBox(height: 16),

            _buildContractCard(
              context,
              title: 'الباقة البرونزية',
              price: '800',
              color: Colors.brown.shade400,
              features: [
                'زيارة صيانة وقائية واحدة',
                'فحص شامل للأجهزة',
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
              color: isRecommended ? color : Colors.grey.shade200,
              width: isRecommended ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
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
                  color: color.withOpacity(0.1),
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
                    Expanded(child: Text(feature)),
                  ],
                ),
              )),
              
              const SizedBox(height: 24),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'اشترك الآن',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isRecommended)
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
