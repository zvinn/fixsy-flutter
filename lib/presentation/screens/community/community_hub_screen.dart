import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/community_question_model.dart';
import '../../../data/services/community_service.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _aiPromptController = TextEditingController();
  final Map<String, TextEditingController> _answerControllers = {};
  final Set<String> _expandedQuestions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    _aiPromptController.dispose();
    for (final c in _answerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getAnswerController(String questionId) {
    return _answerControllers.putIfAbsent(questionId, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider?>(context);
    final questions = communityProvider?.questions ?? CommunityService.getFallbackQuestions();
    final dailyTip = communityProvider?.dailyTip ?? CommunityService.curatedTips[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'مجتمع Fixsy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(
              icon: Icon(Icons.auto_awesome, size: 18),
              text: 'نصيحة اليوم',
            ),
            Tab(
              icon: Icon(Icons.forum_outlined, size: 18),
              text: 'أسئلة وأجوبة',
            ),
            Tab(
              icon: Icon(Icons.psychology_outlined, size: 18),
              text: 'أفكار ذكية (AI)',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Daily Tips
          _buildDailyTipsTab(dailyTip, communityProvider),

          // Tab 2: Q&A Forum
          _buildQaTab(questions, communityProvider),

          // Tab 3: AI Tips
          _buildAiTipsTab(communityProvider),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: DAILY TIPS
  // ---------------------------------------------------------------------------
  Widget _buildDailyTipsTab(CommunityTip tip, CommunityProvider? provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Golden gradient tip card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'نصيحة اليوم المعتمدة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tip.category,
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF78350F),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tip.body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Like button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (provider != null) {
                            provider.likeDailyTip();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFFD97706),
                              content: Text('شكراً لتفاعلك وتشجيعك! ❤️'),
                            ),
                          );
                        },
                        icon: Icon(
                          tip.liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                          size: 18,
                        ),
                        label: Text('${tip.likes} مفيد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tip.liked ? const Color(0xFFFDE68A) : Colors.white,
                          foregroundColor: const Color(0xFFD97706),
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Share button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final text = '💡 نصيحة اليوم من مجتمع Fixsy:\n${tip.title}\n${tip.body}';
                          // ignore: deprecated_member_use
                          Share.share(text);
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('مشاركة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB45309),
                          side: const BorderSide(color: Color(0xFFFDE68A), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          // Next tip action
          OutlinedButton.icon(
            onPressed: () {
              if (provider != null) {
                provider.nextDailyTip();
              }
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('عرض نصيحة أخرى عشوائية'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Q&A FORUM
  // ---------------------------------------------------------------------------
  Widget _buildQaTab(List<CommunityQuestion> questions, CommunityProvider? provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ask Question Dashed Button
        InkWell(
          onTap: () => _showAskQuestionModal(provider),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                style: BorderStyle.solid,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'اطرح سؤالك أو استفسارك للفنيين والمجتمع',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(),

        const SizedBox(height: 18),

        if (questions.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'لا توجد أسئلة بعد، كُن أول من يسأل!',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          ...questions.map((q) => _buildQuestionCard(q, provider)),
      ],
    );
  }

  Widget _buildQuestionCard(CommunityQuestion q, CommunityProvider? provider) {
    final isExpanded = _expandedQuestions.contains(q.id);
    final answerController = _getAnswerController(q.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  q.authorName.isNotEmpty ? q.authorName[0] : 'U',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(q.date),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Text
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Action row
          Row(
            children: [
              // Like Question
              InkWell(
                onTap: () {
                  if (provider != null) {
                    provider.likeQuestion(q.id);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        q.liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        size: 16,
                        color: q.liked ? AppTheme.primaryColor : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${q.likes}',
                        style: TextStyle(
                          color: q.liked ? AppTheme.primaryColor : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Answer Count & Expand
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedQuestions.remove(q.id);
                    } else {
                      _expandedQuestions.add(q.id);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        '${q.answers.length} إجابة',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Answers section
          if (isExpanded || q.answers.isNotEmpty) ...[
            const Divider(height: 24),
            ...q.answers.map(
              (ans) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    right: BorderSide(color: AppTheme.primaryColor, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ans.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          _formatDate(ans.date),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ans.text,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
            ),

            // Add Answer Input
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: answerController,
                    decoration: InputDecoration(
                      hintText: 'اكتب إجابتك أو نصيحتك هنا...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final text = answerController.text.trim();
                    if (text.isEmpty) return;

                    var authorName = 'مستخدم فيكسي';
                    try {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      if (auth.currentUser?.displayName.isNotEmpty == true) {
                        authorName = auth.currentUser!.displayName;
                      }
                    } catch (_) {}

                    if (provider != null) {
                      provider.addAnswer(
                        questionId: q.id,
                        text: text,
                        authorName: authorName,
                      );
                    }
                    answerController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة إجابتك بنجاح!')),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAskQuestionModal(CommunityProvider? provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اطرح سؤالك للمجتمع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'اطرح أي استفسار يخص الصيانة أو الأعطال المنزلية لمشاركة الخبرات',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب سؤالك بوضوح... مثال: كيف أصلح تسريب خلاط المطبخ بدون كسر الماسورة؟',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final text = _questionController.text.trim();
                  if (text.isEmpty) return;

                  var authorName = 'مستخدم فيكسي';
                  try {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    if (auth.currentUser?.displayName.isNotEmpty == true) {
                      authorName = auth.currentUser!.displayName;
                    }
                  } catch (_) {}

                  if (provider != null) {
                    provider.addQuestion(
                      question: text,
                      authorName: authorName,
                    );
                  }
                  _questionController.clear();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.successColor,
                      content: Text('تم نشر سؤالك في المجتمع بنجاح!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'نشر السؤال الآن',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: AI TIPS
  // ---------------------------------------------------------------------------
  Widget _buildAiTipsTab(CommunityProvider? provider) {
    final isGenerating = provider?.isGeneratingAiTip ?? false;
    final aiResult = provider?.aiGeneratedTip;

    final quickTopics = ['تسريب سباكة', 'تنظيف فلاتر التكييف', 'قاطع الكهرباء سقط', 'صيانة غسالة', 'عزل رطوبة الجدران'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مساعد Fixsy الذكي للصيانة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'اكتب أي عطل وسيقدم لك الذكاء الاصطناعي خطوات الإصلاح الفورية',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Topics
          const Text(
            'مواضيع صيانة سريعة:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickTopics.map((topic) {
              return ActionChip(
                label: Text(topic),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () {
                  _aiPromptController.text = topic;
                  if (provider != null) {
                    provider.generateAiTip(topic);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Custom Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _aiPromptController,
                  decoration: InputDecoration(
                    hintText: 'أو اكتب موضوعاً مخصصاً...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isGenerating
                    ? null
                    : () {
                        final text = _aiPromptController.text.trim();
                        if (text.isEmpty) return;
                        if (provider != null) {
                          provider.generateAiTip(text);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                child: isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // AI Response Card
          if (aiResult != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tips_and_updates, color: AppTheme.primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'خطوات الإصلاح المقترحة',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'نسخ النصيحة',
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: aiResult));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ النصيحة إلى الحافظة!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    aiResult,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24 && difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
