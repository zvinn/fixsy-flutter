import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  final String? initialPage;

  const LegalScreen({super.key, this.initialPage});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialPage == 'privacy' ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الشروط والسياسات'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الشروط والأحكام'),
              Tab(text: 'سياسة الخصوصية'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TermsTab(),
            _PrivacyTab(),
          ],
        ),
      ),
    );
  }
}

class _TermsTab extends StatelessWidget {
  const _TermsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'مقدمة',
            'مرحباً بك في تطبيق فيكسي. باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام.',
          ),
          _buildSection(
            'الخدمات',
            'يوفر تطبيق فيكسي منصة لربط العملاء بمقدمي خدمات الصيانة المنزلية. نحن لا نقدم الخدمات مباشرة، بل نسهل التواصل بين الأطراف.',
          ),
          _buildSection(
            'المسؤوليات',
            '• المستخدم مسؤول عن دقة المعلومات المقدمة\n• الفني مسؤول عن جودة الخدمة المقدمة\n• التطبيق غير مسؤول عن أي خلافات بين الأطراف',
          ),
          _buildSection(
            'الدفع',
            'يتم الدفع مباشرة للفني بعد إتمام الخدمة. التطبيق لا يتحمل مسؤولية أي نزاعات مالية.',
          ),
          _buildSection(
            'الإلغاء',
            'يمكن إلغاء الحجز قبل قبول الفني للطلب دون أي رسوم. بعد القبول، قد يتم تطبيق رسوم إلغاء.',
          ),
          _buildSection(
            'التعديلات',
            'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية.',
          ),
          const SizedBox(height: 20),
          Text(
            'آخر تحديث: يناير 2026',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PrivacyTab extends StatelessWidget {
  const _PrivacyTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'جمع البيانات',
            'نجمع المعلومات التالية:\n• الاسم والبريد الإلكتروني\n• رقم الهاتف\n• الموقع (للخدمات)\n• سجل الحجوزات',
          ),
          _buildSection(
            'استخدام البيانات',
            'نستخدم بياناتك لـ:\n• تقديم الخدمات المطلوبة\n• التواصل معك بشأن حجوزاتك\n• تحسين تجربة المستخدم\n• إرسال العروض (بموافقتك)',
          ),
          _buildSection(
            'مشاركة البيانات',
            'نشارك بياناتك فقط مع:\n• الفنيين لإتمام الخدمة\n• شركاء الدفع لمعالجة المعاملات\n• الجهات القانونية عند الطلب',
          ),
          _buildSection(
            'أمان البيانات',
            'نستخدم تشفير SSL وإجراءات أمنية متقدمة لحماية بياناتك. نلتزم بأعلى معايير الأمان.',
          ),
          _buildSection(
            'حقوقك',
            'لديك الحق في:\n• الوصول لبياناتك\n• تصحيح بياناتك\n• حذف حسابك\n• إلغاء الاشتراك في الإشعارات',
          ),
          _buildSection(
            'التواصل',
            'لأي استفسارات حول الخصوصية، تواصل معنا على:\nsupport@fixsy.app',
          ),
          const SizedBox(height: 20),
          Text(
            'آخر تحديث: يناير 2026',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

Widget _buildSection(String title, String content) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
      ],
    ),
  );
}
