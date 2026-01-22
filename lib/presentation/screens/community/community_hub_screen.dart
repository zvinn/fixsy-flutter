import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/common/enhanced_widgets.dart';
import '../../../core/theme/app_theme.dart';

class CommunityHubScreen extends StatelessWidget {
  const CommunityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text('مجتمع Fixsy', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button since it's a tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Tip Section
            _buildDailyTipCard().animate().fadeIn().slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 24),
            
            Text(
              'أحدث النقاشات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Discussion List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildDiscussionCard(index).animate().fadeIn(delay: (100 * index).ms).slideX();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new question
        },
        label: const Text('إضافة سؤال'),
        icon: const Icon(Icons.add_comment_rounded),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              const Text(
                'نصيحة اليوم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'لتوفير استهلاك الكهرباء، افصل الأجهزة الكهربائية غير المستخدمة من المقبس، خاصة الشواحن.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, color: Colors.white, size: 20),
                label: const Text('مشاركة', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=1'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أحمد محمد',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'منذ ساعتين',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50], // Category color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'كهرباء',
                  style: TextStyle(color: Colors.orange[800], fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'عندي مشكلة في القاطع الرئيسي بيفصل كل شوية، ايه السبب؟',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[200]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInteractionButton(Icons.thumb_up_outlined, '12'),
              _buildInteractionButton(Icons.comment_outlined, '5'),
              _buildInteractionButton(Icons.bookmark_border, ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String count) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
