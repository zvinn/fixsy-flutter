import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      Tip(
        icon: Icons.water_drop_outlined,
        title: 'فحص التسريبات شهرياً',
        description: 'افحص الحنفيات والمواسير شهرياً لتجنب مشاكل التسريب الكبيرة',
        category: 'سباكة',
        color: const Color(0xFF0EA5E9),
        bgColor: const Color(0xFFE0F2FE),
      ),
      Tip(
        icon: Icons.bolt_outlined,
        title: 'لا تحمّل الفيش الكثير',
        description: 'تجنب توصيل أجهزة كثيرة في فيشة واحدة لمنع الحرائق',
        category: 'كهرباء',
        color: const Color(0xFFEAB308),
        bgColor: const Color(0xFFFEF9C3),
      ),
      Tip(
        icon: Icons.ac_unit_outlined,
        title: 'نظّف فلتر التكييف',
        description: 'نظّف فلتر التكييف كل 2-3 أسابيع للحفاظ على كفاءته',
        category: 'تكييف',
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFD1FAE5),
      ),
      Tip(
        icon: Icons.build_outlined,
        title: 'احتفظ بأدوات أساسية',
        description: 'مفك، كماشة، شريط لاصق - أدوات تنقذك في الطوارئ',
        category: 'عام',
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFEDE9FE),
      ),
      Tip(
        icon: Icons.shield_outlined,
        title: 'اعرف مكان المفاتيح',
        description: 'تأكد من معرفة مكان قاطع الكهرباء الرئيسي ومحبس المياه',
        category: 'سلامة',
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEE2E2),
      ),
      Tip(
        icon: Icons.schedule_outlined,
        title: 'الصيانة الدورية أرخص',
        description: 'الصيانة الوقائية توفر لك 70% من تكاليف الإصلاح',
        category: 'صيانة',
        color: const Color(0xFFF97316),
        bgColor: const Color(0xFFFFEDD5),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('نصائح وحيل'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCD34D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      size: 32,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نصائح وحيل',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        Text(
                          'اعرف أكتر عن صيانة بيتك',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFFB45309).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tips List
            ...tips.map((tip) => _buildTipCard(tip)).toList(),

            // CTA
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'محتاج مساعدة؟ احجز فني متخصص الآن!',
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(Tip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tip.bgColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tip.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(tip.icon, color: tip.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tip.bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tip.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tip.color,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline, color: tip.color.withOpacity(0.5), size: 18),
        ],
      ),
    );
  }
}

class Tip {
  final IconData icon;
  final String title;
  final String description;
  final String category;
  final Color color;
  final Color bgColor;

  Tip({
    required this.icon,
    required this.title,
    required this.description,
    required this.category,
    required this.color,
    required this.bgColor,
  });
}
