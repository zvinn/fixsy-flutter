import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Minimal Service Card - Clean design without gradients
class EnhancedServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final List<Color>? gradientColors; // Kept for compatibility but ignored

  const EnhancedServiceCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Simple Icon - no background
              Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
              
              const Spacer(),
              
              // Text Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stats Card Widget
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(color: AppTheme.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend!,
                    style: const TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: const Row(
              children: [
                Text('عرض الكل'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
      ],
    );
  }
}

/// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
