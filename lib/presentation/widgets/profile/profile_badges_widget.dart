import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Badge model
class ProfileBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int? progress;
  final int? target;

  const ProfileBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress,
    this.target,
  });
  
  double get progressPercent {
    if (isUnlocked) return 1.0;
    if (progress == null || target == null || target == 0) return 0.0;
    return (progress! / target!).clamp(0.0, 1.0);
  }
}

/// Default badges list
class BadgesList {
  static List<ProfileBadge> getDefaultBadges({
    int completedBookings = 0,
    int totalReviews = 0,
    bool isVerified = false,
    int referrals = 0,
  }) {
    return [
      ProfileBadge(
        id: 'first_booking',
        title: 'أول حجز',
        description: 'أكملت أول طلب صيانة',
        icon: Icons.celebration,
        color: Colors.amber,
        isUnlocked: completedBookings > 0,
        progress: completedBookings > 0 ? 1 : 0,
        target: 1,
      ),
      ProfileBadge(
        id: 'regular_user',
        title: 'مستخدم نشط',
        description: 'أكملت 5 طلبات',
        icon: Icons.star,
        color: Colors.blue,
        isUnlocked: completedBookings >= 5,
        progress: completedBookings,
        target: 5,
      ),
      ProfileBadge(
        id: 'vip',
        title: 'عميل VIP',
        description: 'أكملت 20 طلب',
        icon: Icons.diamond,
        color: Colors.purple,
        isUnlocked: completedBookings >= 20,
        progress: completedBookings,
        target: 20,
      ),
      ProfileBadge(
        id: 'verified',
        title: 'حساب موثق',
        description: 'تم التحقق من هويتك',
        icon: Icons.verified,
        color: Colors.green,
        isUnlocked: isVerified,
      ),
      ProfileBadge(
        id: 'reviewer',
        title: 'مقيّم',
        description: 'قمت بتقييم 3 فنيين',
        icon: Icons.rate_review,
        color: Colors.orange,
        isUnlocked: totalReviews >= 3,
        progress: totalReviews,
        target: 3,
      ),
      ProfileBadge(
        id: 'ambassador',
        title: 'سفير Fixsy',
        description: 'قمت بدعوة 5 أصدقاء',
        icon: Icons.groups,
        color: Colors.teal,
        isUnlocked: referrals >= 5,
        progress: referrals,
        target: 5,
      ),
    ];
  }
}

/// Profile Badges Widget
class ProfileBadgesWidget extends StatelessWidget {
  final List<ProfileBadge> badges;
  final bool showAll;
  final VoidCallback? onViewAll;

  const ProfileBadgesWidget({
    super.key,
    required this.badges,
    this.showAll = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayBadges = showAll ? badges : badges.take(4).toList();
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.military_tech,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الشارات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unlockedCount/${badges.length}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (!showAll && onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('عرض الكل'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: displayBadges.asMap().entries.map((entry) {
              final index = entry.key;
              final badge = entry.value;
              return _BadgeItem(
                badge: badge,
                isDark: isDark,
              ).animate().fadeIn(delay: (100 * index).ms).scale();
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final ProfileBadge badge;
  final bool isDark;

  const _BadgeItem({
    required this.badge,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badge.isUnlocked
                        ? badge.color.withOpacity(0.15)
                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                    border: Border.all(
                      color: badge.isUnlocked
                          ? badge.color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    badge.icon,
                    color: badge.isUnlocked
                        ? badge.color
                        : (isDark ? Colors.white24 : Colors.grey.shade400),
                    size: 28,
                  ),
                ),
                if (!badge.isUnlocked && badge.progressPercent > 0)
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: badge.progressPercent,
                      strokeWidth: 2,
                      backgroundColor: Colors.transparent,
                      color: badge.color.withOpacity(0.5),
                    ),
                  ),
                if (badge.isUnlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppTheme.darkBackground : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              badge.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: badge.isUnlocked ? FontWeight.w600 : FontWeight.normal,
                color: badge.isUnlocked
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white38 : Colors.black38),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.isUnlocked
                    ? badge.color.withOpacity(0.15)
                    : (isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: Icon(
                badge.icon,
                color: badge.isUnlocked
                    ? badge.color
                    : (isDark ? Colors.white24 : Colors.grey.shade400),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            if (!badge.isUnlocked && badge.target != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: badge.progressPercent,
                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(badge.color),
              ),
              const SizedBox(height: 8),
              Text(
                '${badge.progress ?? 0} / ${badge.target}',
                style: TextStyle(
                  color: badge.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (badge.isUnlocked && badge.unlockedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'تم الحصول عليها في ${_formatDate(badge.unlockedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
