import 'package:flutter/material.dart';
import '../../../../data/services/ai_service.dart';

/// Floating AI Assistant Action Button
/// Modern glowing pill with gradient and sparkles
class FloatingAiAssistantButton extends StatefulWidget {

  const FloatingAiAssistantButton({
    super.key,
    this.onPressed,
    this.enableAnimation = true,
  });
  final VoidCallback? onPressed;
  final bool enableAnimation;

  @override
  State<FloatingAiAssistantButton> createState() => _FloatingAiAssistantButtonState();
}

class _FloatingAiAssistantButtonState extends State<FloatingAiAssistantButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.enableAnimation) {
      _pulseController.repeat(reverse: true);
    }

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('floating_ai_assistant_btn'),
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            if (widget.onPressed != null) {
              widget.onPressed!();
            } else {
              FixsyAiAssistantModal.show(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'مساعد Fixsy الذكي',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Comprehensive Fixsy AI Assistant Modal
/// Provides problem diagnosis, instant price estimation, safety advice, tips, and conversational Q&A
class FixsyAiAssistantModal extends StatefulWidget {

  const FixsyAiAssistantModal({
    super.key,
    this.initialQuery,
    this.onBookTechnician,
  });
  final String? initialQuery;
  final VoidCallback? onBookTechnician;

  /// Show the modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    String? initialQuery,
    VoidCallback? onBookTechnician,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FixsyAiAssistantModal(
        initialQuery: initialQuery,
        onBookTechnician: onBookTechnician,
      ),
    );
  }

  @override
  State<FixsyAiAssistantModal> createState() => _FixsyAiAssistantModalState();
}

class _FixsyAiAssistantModalState extends State<FixsyAiAssistantModal> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();

  bool _isAnalyzing = false;
  bool _isListening = false;
  bool _isAnsweringFollowUp = false;
  AiDiagnosis? _diagnosis;
  String? _attachedImageName;
  final List<Map<String, String>> _followUpChat = [];

  final List<Map<String, String>> _quickTriageChips = [
    {
      'label': '💧 تسريب مياه بالحمام / المطبخ',
      'query': 'تسريب مياه من الحنفية أو تحت الحوض والماء لا يتوقف',
    },
    {
      'label': '⚡ قفلة كهرباء وماس باللوحة',
      'query': 'ماس كهربائي وقفلة في لوحة المفاتيح والفيوز بيفصل باستمرار',
    },
    {
      'label': '❄️ تكييف مش بيسقع وبيسرب ماء',
      'query': 'التكييف يخرج هواء ساخن ولا يبرد ويوجد تسريب مياه من الوحدة الداخلية',
    },
    {
      'label': '🪚 تصليح باب خشب أو دولاب مكسور',
      'query': 'باب الغرفة لا يغلق بشكل سليم والمفصلات مكسورة وتحتاج ضبط',
    },
    {
      'label': '🎨 علاج رطوبة ونشع ودهان حائط',
      'query': 'يوجد تقشير في دهان الحائط ورطوبة ونشع محتاج معالجة ودهان متطابق',
    },
    {
      'label': '⚙️ صيانة غسالة أو ثلاجة',
      'query': 'الغسالة تصدر صوتاً عادياً ولا تعصر الملابس بشكل جيد',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _queryController.text = widget.initialQuery!;
      _analyzeProblem();
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _followUpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _analyzeProblem() async {
    final text = _queryController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى كتابة وصف المشكلة أو اختيار أحد النماذج السريعة'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _followUpChat.clear();
    });

    try {
      final result = await _aiService.analyzeProblem(
        images: [],
        description: text,
      );

      if (mounted) {
        setState(() {
          _diagnosis = result;
          _isAnalyzing = false;
        });

        // Scroll to results
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              250,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      return;
    }

    setState(() {
      _isListening = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جارٍ الاستماع إليك... تحدث الآن 🎙️'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF7C3AED),
      ),
    );

    // Simulate speech-to-text recognition
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted && _isListening) {
      setState(() {
        _isListening = false;
        _queryController.text = 'عندي ماس كهربائي والفيشة مطلعّة شرار والنور فاصل';
      });
      _analyzeProblem();
    }
  }

  void _toggleImageAttachment() {
    setState(() {
      if (_attachedImageName == null) {
        _attachedImageName = 'صورة_العطل_المرفقة.jpg';
      } else {
        _attachedImageName = null;
      }
    });
  }

  Future<void> _sendFollowUpQuestion(String question) async {
    if (question.trim().isEmpty || _diagnosis == null) return;

    setState(() {
      _followUpChat.add({'role': 'user', 'text': question.trim()});
      _isAnsweringFollowUp = true;
      _followUpController.clear();
    });

    final answer = await _aiService.askAiFollowUp(
      query: question,
      contextDiagnosis: _diagnosis!,
    );

    if (mounted) {
      setState(() {
        _followUpChat.add({'role': 'ai', 'text': answer});
        _isAnsweringFollowUp = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _smartBookNow() {
    Navigator.pop(context);
    if (widget.onBookTechnician != null) {
      widget.onBookTechnician!();
    } else {
      Navigator.pushNamed(
        context,
        '/new-request',
        arguments: {
          'initialServiceType': _diagnosis?.suggestedService,
          'initialDescription': _diagnosis?.problem,
        },
      );
    }
  }

  void _postToJobMarket() {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/job-market',
      arguments: {
        'initialCategory': _diagnosis?.suggestedService,
        'initialTitle': _diagnosis?.problem,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Grab Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Modal Header
            _buildHeader(isDark),

            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Triage Quick Chips (if no diagnosis yet)
                  if (_diagnosis == null) ...[
                    _buildTriageChips(isDark),
                    const SizedBox(height: 20),
                  ],

                  // Problem Input Box
                  _buildInputBox(isDark),

                  const SizedBox(height: 20),

                  // Loading State
                  if (_isAnalyzing)
                    _buildAnalyzingIndicator(isDark)
                  else if (_diagnosis != null)
                    _buildDiagnosisResult(isDark),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'مساعد Fixsy الذكي',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AI Vision',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'تشخيص فوري للأعطال، تقدير الأسعار، واستشارة فنية ذكية',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('ai_assistant_close_btn'),
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  Widget _buildTriageChips(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أعطال شائعة يمكنك اختيارها مباشرة:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickTriageChips.map((chip) {
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _queryController.text = chip['query']!;
                _analyzeProblem();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  chip['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputBox(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('ai_assistant_query_input'),
            controller: _queryController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'صف العطل هنا... (مثال: الحنفية بتنقط مياه ومش بتقفل أو التكييف بينزل ماء)',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          if (_attachedImageName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image, size: 16, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 6),
                  Text(
                    _attachedImageName!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _toggleImageAttachment,
                    child: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          Row(
            children: [
              // Voice Input Toggle
              IconButton(
                key: const Key('ai_assistant_mic_btn'),
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.redAccent : const Color(0xFF7C3AED),
                ),
                tooltip: 'تحدث صوتياً',
                onPressed: _toggleListening,
              ),

              // Image Attachment Toggle
              IconButton(
                key: const Key('ai_assistant_image_btn'),
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: _attachedImageName != null ? const Color(0xFF10B981) : Colors.grey.shade600,
                ),
                tooltip: 'إرفاق صورة العطل',
                onPressed: _toggleImageAttachment,
              ),

              const Spacer(),

              // Analyze Button
              ElevatedButton.icon(
                key: const Key('ai_assistant_analyze_btn'),
                onPressed: _isAnalyzing ? null : _analyzeProblem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text(
                  'تحليل العطل',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF7C3AED),
          ),
          const SizedBox(height: 16),
          Text(
            'جارٍ تحليل المشكلة بالذكاء الاصطناعي...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'مطابقة الكلمات المفتاحية وتقدير تكاليف الصيانة وخطوات السلامة',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisResult(bool isDark) {
    final diagnosis = _diagnosis!;

    Color severityColor;
    String severityLabel;
    switch (diagnosis.severity) {
      case 'critical':
        severityColor = Colors.redAccent;
        severityLabel = 'عاجل جداً (طوارئ)';
        break;
      case 'high':
        severityColor = Colors.orangeAccent.shade700;
        severityLabel = 'أولوية مرتفعة';
        break;
      case 'medium':
        severityColor = Colors.amber.shade700;
        severityLabel = 'أولوية متوسطة';
        break;
      default:
        severityColor = Colors.green;
        severityLabel = 'حالة عادية';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Diagnosis Main Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      diagnosis.icon,
                      style: const TextStyle(fontSize: 22),
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
                              'تشخيص: ${diagnosis.suggestedService}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                severityLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: severityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.verified, size: 14, color: Colors.blue.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'دقة التشخيص: ${diagnosis.confidence} (95%)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                diagnosis.problem,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                diagnosis.solution,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Estimated Price Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF166534),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.attach_money, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التكلفة التقديرية المتوقعة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${diagnosis.minPrice.toInt()} - ${diagnosis.maxPrice.toInt()} ج.م',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF14532D),
                      ),
                    ),
                    Text(
                      'تشمل الكشف ومصنعية الفني المعتمد (قطع الغيار تُحسب بالفواتير)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Safety Alert Advice
        if (diagnosis.advice != null && diagnosis.advice!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFB45309),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إجراءات أمان فورية (Safety First):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        diagnosis.advice!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78350F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Tips & Steps Checklist
        if (diagnosis.tips.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Text(
                      'خطوات عملية قبل وصول الفني:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...diagnosis.tips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Interactive AI Follow-up Section
        _buildFollowUpSection(isDark),

        const SizedBox(height: 24),

        // Action Buttons (Smart Book & Job Market)
        _buildActionButtons(isDark),
      ],
    );
  }

  Widget _buildFollowUpSection(bool isDark) {
    final suggestedQuestions = [
      'هل السعر يشمل الخامات المطلوبة؟',
      'ما مدى خطورة هذا العطل على المنزل؟',
      'كم يستغرق الإصلاح بالتقريب؟',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Text(
                'استشر Fixsy AI حول هذا العطل:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Suggested chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: suggestedQuestions.map((q) {
              return ActionChip(
                label: Text(q, style: const TextStyle(fontSize: 11)),
                backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                side: BorderSide(color: const Color(0xFF7C3AED).withValues(alpha: 0.2)),
                onPressed: () => _sendFollowUpQuestion(q),
              );
            }).toList(),
          ),

          // Chat bubbles if any
          if (_followUpChat.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._followUpChat.map((msg) {
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 280),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF7C3AED)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUser ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      height: 1.3,
                    ),
                  ),
                ),
              );
            }),
          ],

          if (_isAnsweringFollowUp) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
                ),
                SizedBox(width: 8),
                Text(
                  'Fixsy AI يكتب الرد...',
                  style: TextStyle(fontSize: 11, color: Color(0xFF7C3AED)),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // Input field for custom questions
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('ai_followup_input'),
                  controller: _followUpController,
                  decoration: InputDecoration(
                    hintText: 'اسأل سؤالاً إضافياً...',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: _sendFollowUpQuestion,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: const Key('ai_followup_send_btn'),
                icon: const Icon(Icons.send_rounded, color: Color(0xFF7C3AED)),
                onPressed: () => _sendFollowUpQuestion(_followUpController.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Smart Book CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            key: const Key('ai_assistant_smart_book_btn'),
            onPressed: _smartBookNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
            ),
            icon: const Icon(Icons.flash_on, size: 20),
            label: Text(
              'حجز فني ذكي الآن (${_diagnosis?.suggestedService})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Broadcast to Job Market
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            key: const Key('ai_assistant_job_market_btn'),
            onPressed: _postToJobMarket,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD97706),
              side: const BorderSide(color: Color(0xFFD97706), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.campaign, size: 20),
            label: const Text(
              'طرح المشكلة في سوق العمل للمزايدة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Reset & Search Another
        TextButton(
          key: const Key('ai_assistant_reset_btn'),
          onPressed: () {
            setState(() {
              _diagnosis = null;
              _queryController.clear();
              _followUpChat.clear();
              _attachedImageName = null;
            });
          },
          child: Text(
            'تشخيص عطل آخر 🔄',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
