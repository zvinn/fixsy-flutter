import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSending = false;

  final List<FAQ> _faqs = [
    FAQ(
      question: 'كيف أحجز خدمة؟',
      answer: 'اختر الخدمة المطلوبة -> اختر الفني -> حدد الموعد والموقع -> أكد الحجز.',
    ),
    FAQ(
      question: 'ما هي طرق الدفع المتاحة؟',
      answer: 'يمكنك الدفع نقداً عند الانتهاء أو من رصيد المحفظة.',
    ),
    FAQ(
      question: 'هل يمكنني إلغاء الحجز؟',
      answer: 'نعم، يمكنك إلغاء الحجز قبل قبول الفني للطلب.',
    ),
    FAQ(
      question: 'هل توجد ضمانات على الخدمة؟',
      answer: 'نعم، جميع الفنيين الموثقين يقدمون ضمان 14 يوم على أعمالهم.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مركز المساعدة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'الأسئلة الشائعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFAQList(),
            const SizedBox(height: 24),

            // Contact Form
            _buildContactForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'دردشة مباشرة',
            color: AppTheme.primaryColor,
            bgColor: AppTheme.primaryColor.withOpacity(0.1),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الدردشة المباشرة قريباً')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.phone_outlined,
            title: 'اتصل بنا',
            color: AppTheme.successColor,
            bgColor: AppTheme.successColor.withOpacity(0.1),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('خدمة الاتصال قريباً')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    return Column(
      children: _faqs.asMap().entries.map((entry) {
        final index = entry.key;
        final faq = entry.value;
        final isExpanded = _expandedIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColorLight),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    faq.answer,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColorLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'لا زلت تحتاج مساعدة؟',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'صف مشكلتك',
              prefixIcon: Icon(Icons.message_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSending ? 'جاري الإرسال...' : 'إرسال الرسالة'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة رسالتك')),
      );
      return;
    }

    setState(() => _isSending = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSending = false);
    _messageController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال رسالتك بنجاح! سنرد عليك قريباً.')),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});
}
