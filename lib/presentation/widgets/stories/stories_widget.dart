import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

/// Model for a Story
class Story {
  final String id;
  final String techId;
  final String techName;
  final String techImg;
  final String specialty;
  final String media;
  final String type; // 'image' or 'video'
  final DateTime timestamp;
  final String caption;
  final String serviceCategory;
  final bool isVerified;

  Story({
    required this.id,
    required this.techId,
    required this.techName,
    required this.techImg,
    this.specialty = 'فني معتمد',
    required this.media,
    required this.type,
    required this.timestamp,
    this.caption = '',
    this.serviceCategory = 'صيانة عامة',
    this.isVerified = true,
  });

  bool get isExpired => DateTime.now().difference(timestamp).inHours >= 24;
}

/// Stories Widget - Instagram-like daily stories for technicians
class StoriesWidget extends StatefulWidget {
  final String? userRole;
  final String? userId;

  const StoriesWidget({
    super.key,
    this.userRole,
    this.userId,
  });

  @override
  State<StoriesWidget> createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  final ImagePicker _picker = ImagePicker();
  List<Story> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() => _isLoading = true);

    try {
      _stories = [
        Story(
          id: '1',
          techId: 'tech_01',
          techName: 'م. أحمد حسني',
          techImg: '',
          specialty: 'خبير سباكة وتأسيس شبكات',
          serviceCategory: 'سباكة',
          caption: 'تم الانتهاء من فحص وتصليح تسريب مخفي في شبكة التغذية الرئيسية بالمعادي 🔧💧',
          media: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
          type: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        Story(
          id: '2',
          techId: 'tech_02',
          techName: 'م. محمود سامي',
          techImg: '',
          specialty: 'فني تكييف وتبريد معتمد',
          serviceCategory: 'تكييف',
          caption: 'تنظيف وغسيل دوري للوحدات الخارجية وشحن فريون أصلي مع ضمان صيف كامل ❄️⚡',
          media: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800',
          type: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Story(
          id: '3',
          techId: 'tech_03',
          techName: 'م. علي الجوهري',
          techImg: '',
          specialty: 'أعمال الكهرباء واللوحات الذكية',
          serviceCategory: 'كهرباء',
          caption: 'تركيب لوحة قواطع ذكية وحماية ضد تذبذب التيار الكهربائي للمنزل 💡🛡️',
          media: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
          type: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        Story(
          id: '4',
          techId: 'tech_04',
          techName: 'طارق عبد العزيز',
          techImg: '',
          specialty: 'نجارة وديكورات خشبية',
          serviceCategory: 'نجارة',
          caption: 'تجديد وصيانة أبواب وشبابيك عازلة للصوت والحرارة بأحدث المفصلات الهيدروليكية 🚪✨',
          media: 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=800',
          type: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 9)),
        ),
      ];
    } catch (e) {
      debugPrint('Error loading stories: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddStoryModal() {
    final captionController = TextEditingController();
    String selectedCategory = 'سباكة';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'نشر قصة يومية جديدة (Story)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'شارك عملاءك بصور من أعمالك اليومية، تختفي القصة تلقائياً بعد 24 ساعة.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Category chips
                const Text('نوع الخدمة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['سباكة', 'تكييف', 'كهرباء', 'نجارة', 'نقاشة'].map((cat) {
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setModalState(() => selectedCategory = cat);
                      },
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Caption
                TextField(
                  controller: captionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'اكتب وصفاً مختصراً للعمل المنجز...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Publish Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final caption = captionController.text.trim();
                      if (caption.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('الرجاء كتابة وصف للقصة')),
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      setState(() {
                        _stories.insert(
                          0,
                          Story(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            techId: widget.userId ?? 'my_tech_id',
                            techName: 'أنا (الفني)',
                            techImg: '',
                            specialty: 'فني $selectedCategory معتمد',
                            serviceCategory: selectedCategory,
                            caption: caption,
                            media: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
                            type: 'image',
                            timestamp: DateTime.now(),
                          ),
                        );
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppTheme.successColor,
                          content: Text('تم نشر قصتك بنجاح وستظهر لجميع العملاء! 🎉'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('نشر القصة الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _viewStory(Story story) {
    final techStories = _stories.where((s) => s.techId == story.techId).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerScreen(
          stories: techStories.isNotEmpty ? techStories : [story],
          initialIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return SizedBox(
        height: 106,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) => _buildSkeletonItem(isDark),
        ),
      );
    }

    // Group stories by technician
    final Map<String, List<Story>> groupedStories = {};
    for (final story in _stories.where((s) => !s.isExpired)) {
      groupedStories.putIfAbsent(story.techId, () => []).add(story);
    }

    return SizedBox(
      height: 106,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: groupedStories.length + 1, // First item is always the Add/My Story item
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryButton(isDark);
          }

          final adjustedIndex = index - 1;
          final techId = groupedStories.keys.elementAt(adjustedIndex);
          final stories = groupedStories[techId]!;
          final latestStory = stories.first;

          return _buildStoryItem(latestStory, isDark, stories.length);
        },
      ),
    );
  }

  Widget _buildAddStoryButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showAddStoryModal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: AppTheme.primaryColor, size: 36),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'أضف قصتك',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStoryItem(Story story, bool isDark, int storyCount) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _viewStory(story),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF38BDF8),
                    Color(0xFFF59E0B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppTheme.darkBackground : Colors.white,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: story.techImg.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: story.techImg,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          child: Center(
                            child: Text(
                              story.techName[0],
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                story.techName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildSkeletonItem(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 50,
            height: 10,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1000.ms);
  }
}

/// Full screen story viewer
class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  bool _isPaused = false;
  String? _selectedReaction;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _progressController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _pauseStory() {
    if (!_isPaused) {
      _progressController.stop();
      setState(() => _isPaused = true);
    }
  }

  void _resumeStory() {
    if (_isPaused) {
      _progressController.forward();
      setState(() => _isPaused = false);
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onLongPressStart: (_) => _pauseStory(),
          onLongPressEnd: (_) => _resumeStory(),
          onTapUp: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.localPosition.dx > screenWidth * 0.65) {
              _previousStory();
            } else if (details.localPosition.dx < screenWidth * 0.35) {
              _nextStory();
            }
          },
          child: Stack(
            children: [
              // Story Media
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.stories.length,
                itemBuilder: (context, index) {
                  final s = widget.stories[index];
                  return CachedNetworkImage(
                    imageUrl: s.media,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, color: Colors.white70, size: 48),
                          const SizedBox(height: 8),
                          Text(s.serviceCategory, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Gradient Overlay for header and footer readability
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0.0, 0.2, 0.7, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Top Progress Bars
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                right: 12,
                child: Row(
                  children: List.generate(widget.stories.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: index == _currentIndex
                            ? AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return FractionallySizedBox(
                                    alignment: Alignment.centerRight,
                                    widthFactor: _progressController.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : index < _currentIndex
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                : null,
                      ),
                    );
                  }),
                ),
              ),

              // Header with Tech Info
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.techProfile,
                          arguments: {
                            'techId': story.techId,
                            'techName': story.techName,
                            'specialty': story.specialty,
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          story.techName[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.techProfile,
                            arguments: {
                              'techId': story.techId,
                              'techName': story.techName,
                              'specialty': story.specialty,
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  story.techName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (story.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Colors.blue, size: 14),
                                ],
                              ],
                            ),
                            Text(
                              '${story.specialty} • ${_formatTime(story.timestamp)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Reaction Float Animation
              if (_selectedReaction != null)
                Center(
                  child: Text(
                    _selectedReaction!,
                    style: const TextStyle(fontSize: 72),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeOut(delay: 500.ms),
                ),

              // Caption & Bottom Action Bar
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Caption
                    if (story.caption.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          story.caption,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Quick Reactions Row
                    Row(
                      children: ['👏', '🔥', '👍', '❤️', '🛠️'].map((emoji) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedReaction = emoji);
                              Future.delayed(const Duration(milliseconds: 1000), () {
                                if (mounted) setState(() => _selectedReaction = null);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Text(emoji, style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Direct Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.newRequest);
                            },
                            icon: const Icon(Icons.handyman, size: 18),
                            label: const Text('طلب هذا الفني الآن'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.chat,
                                arguments: {
                                  'conversationId': 'story_${story.techId}',
                                  'otherUserName': story.techName,
                                  'otherUserId': story.techId,
                                },
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: const Text('محادثة'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'منذ ${diff.inHours} ساعة';
    }
  }
}
