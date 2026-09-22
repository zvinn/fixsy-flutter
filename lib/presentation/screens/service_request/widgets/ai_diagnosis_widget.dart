import 'package:flutter/material.dart';
import '../../../../data/services/ai_service.dart';
import '../../../../core/theme/app_theme.dart';

class AiDiagnosisWidget extends StatelessWidget {
  final AiDiagnosis diagnosis;
  final VoidCallback? onApplyService;

  const AiDiagnosisWidget({
    super.key,
    required this.diagnosis,
    this.onApplyService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تشخيص الذكاء الاصطناعي الفوري',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'فحص تقني وتحليل شامل للعطل',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(diagnosis.confidence).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getConfidenceColor(diagnosis.confidence).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 14,
                      color: _getConfidenceColor(diagnosis.confidence),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      diagnosis.confidence,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getConfidenceColor(diagnosis.confidence),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFDBEAFE)),
          const SizedBox(height: 16),
          
          // Problem
          _buildInfoRow(
            context,
            icon: Icons.search_rounded,
            label: 'المشكلة المكتشفة',
            value: diagnosis.problem,
            iconColor: const Color(0xFFD97706),
          ),
          const SizedBox(height: 12),
          
          // Suggested Service
          _buildInfoRow(
            context,
            icon: Icons.handyman_rounded,
            label: 'الخدمة المقترحة',
            value: diagnosis.suggestedService,
            iconColor: const Color(0xFF059669),
          ),
          const SizedBox(height: 12),
          
          // Solution
          _buildInfoRow(
            context,
            icon: Icons.lightbulb_rounded,
            label: 'الحل والتوصيات الفنية',
            value: diagnosis.solution,
            iconColor: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 14),
          
          // Estimated Price Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: AppTheme.primaryColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'التكلفة التقديرية المتوقعة:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${diagnosis.estimatedPrice.toStringAsFixed(0)} ريال',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'هذا التقييم استرشادي لمساعدتك. سيتم اعتماد التكلفة النهائية بعد معاينة الفني المعتمد.',
                    style: TextStyle(fontSize: 11, color: Colors.brown.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(String confidence) {
    final lower = confidence.toLowerCase();
    if (lower.contains('عالي') || lower.contains('عالية') || lower.contains('high')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('متوسط') || lower.contains('متوسطة') || lower.contains('med')) {
      return const Color(0xFFF59E0B);
    }
    if (lower.contains('منخفض') || lower.contains('منخفضة') || lower.contains('low')) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF3B82F6);
  }
}
