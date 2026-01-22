import 'package:flutter/material.dart';
import '../../../../data/services/ai_service.dart';

class AiDiagnosisWidget extends StatelessWidget {
  final AiDiagnosis diagnosis;

  const AiDiagnosisWidget({
    super.key,
    required this.diagnosis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'تشخيص الذكاء الاصطناعي',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Problem
            _buildInfoRow(
              context,
              icon: Icons.error_outline,
              label: 'المشكلة',
              value: diagnosis.problem,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            
            // Suggested Service
            _buildInfoRow(
              context,
              icon: Icons.build,
              label: 'الخدمة المقترحة',
              value: diagnosis.suggestedService,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            
            // Solution
            _buildInfoRow(
              context,
              icon: Icons.lightbulb_outline,
              label: 'الحل المقترح',
              value: diagnosis.solution,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            
            // Estimated Price
            _buildInfoRow(
              context,
              icon: Icons.attach_money,
              label: 'التكلفة المتوقعة',
              value: '${diagnosis.estimatedPrice.toStringAsFixed(0)} ريال',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            
            // Confidence
            Row(
              children: [
                const Icon(Icons.verified, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'مستوى الثقة: ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(diagnosis.confidence),
                  backgroundColor: _getConfidenceColor(diagnosis.confidence),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'هذا التشخيص تقديري. سيقوم الفني بالفحص الدقيق عند الزيارة.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence) {
      case 'عالي':
        return Colors.green;
      case 'متوسط':
        return Colors.orange;
      case 'منخفض':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
