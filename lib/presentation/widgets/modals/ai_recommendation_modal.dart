import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/ai_service.dart';

/// AI Recommendation Modal - Shows AI-powered technician recommendations
class AIRecommendationModal extends StatefulWidget {
  final String serviceType;
  final String? problemDescription;
  final VoidCallback? onSelectTechnician;

  const AIRecommendationModal({
    super.key,
    required this.serviceType,
    this.problemDescription,
    this.onSelectTechnician,
  });

  /// Show the modal
  static Future<void> show(
    BuildContext context, {
    required String serviceType,
    String? problemDescription,
    VoidCallback? onSelectTechnician,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIRecommendationModal(
        serviceType: serviceType,
        problemDescription: problemDescription,
        onSelectTechnician: onSelectTechnician,
      ),
    );
  }

  @override
  State<AIRecommendationModal> createState() => _AIRecommendationModalState();
}

class _AIRecommendationModalState extends State<AIRecommendationModal> {
  bool _isLoading = true;
  String? _recommendation;
  List<Map<String, dynamic>> _suggestedTechnicians = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);

    try {
      // Get AI recommendation
      final aiService = AiService();
      _recommendation = await aiService.getServiceRecommendation(
        serviceType: widget.serviceType,
        problemDescription: widget.problemDescription,
      );

      // Sample technicians based on service type
      _suggestedTechnicians = [
        {
          'id': '1',
          'name': 'محمد علي',
          'specialty': widget.serviceType,
          'rating': 4.9,
          'completedJobs': 127,
          'price': 150,
          'distance': '1.2 كم',
          'isVerified': true,
          'matchScore': 95,
        },
        {
          'id': '2',
          'name': 'أحمد حسن',
          'specialty': widget.serviceType,
          'rating': 4.7,
          'completedJobs': 89,
          'price': 120,
          'distance': '2.5 كم',
          'isVerified': true,
          'matchScore': 88,
        },
        {
          'id': '3',
          'name': 'علي محمود',
          'specialty': widget.serviceType,
          'rating': 4.5,
          'completedJobs': 65,
          'price': 100,
          'distance': '3.8 كم',
          'isVerified': false,
          'matchScore': 75,
        },
      ];
    } catch (e) {
      _recommendation = 'عذراً، لم نتمكن من الحصول على توصيات الآن.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'توصية الذكاء الاصطناعي',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'أفضل الفنيين لخدمة ${widget.serviceType}',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: _LoadingAnimation())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Recommendation Card
                        if (_recommendation != null)
                          _RecommendationCard(
                            recommendation: _recommendation!,
                            isDark: isDark,
                          ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 24),

                        // Suggested Technicians
                        Text(
                          'الفنيين المقترحين',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ..._suggestedTechnicians.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tech = entry.value;
                          return _TechnicianCard(
                            technician: tech,
                            isDark: isDark,
                            onSelect: () {
                              Navigator.pop(context);
                              widget.onSelectTechnician?.call();
                            },
                          ).animate().fadeIn(delay: (150 * index).ms);
                        }),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LoadingAnimation extends StatelessWidget {
  const _LoadingAnimation();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.psychology,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        ).animate(onPlay: (c) => c.repeat())
          .scale(duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
          .then()
          .scale(duration: 1000.ms, begin: const Offset(1.1, 1.1), end: const Offset(1, 1)),
        const SizedBox(height: 24),
        Text(
          'جاري تحليل طلبك...',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'نبحث عن أفضل الفنيين لك',
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String recommendation;
  final bool isDark;

  const _RecommendationCard({
    required this.recommendation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  final Map<String, dynamic> technician;
  final bool isDark;
  final VoidCallback onSelect;

  const _TechnicianCard({
    required this.technician,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final matchScore = technician['matchScore'] as int;
    final isVerified = technician['isVerified'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Match Score Badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getScoreColor(matchScore).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$matchScore%',
                    style: TextStyle(
                      color: _getScoreColor(matchScore),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          technician['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.blue.shade400,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${technician['rating']}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${technician['completedJobs']} طلب)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${technician['price']} ج.م',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        technician['distance'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('اختيار هذا الفني'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
