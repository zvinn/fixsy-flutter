import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

/// Model for a Story
class Story {
  final String id;
  final String techId;
  final String techName;
  final String techImg;
  final String media;
  final String type; // 'image' or 'video'
  final DateTime timestamp;

  Story({
    required this.id,
    required this.techId,
    required this.techName,
    required this.techImg,
    required this.media,
    required this.type,
    required this.timestamp,
  });

  bool get isExpired => DateTime.now().difference(timestamp).inHours >= 24;
}

/// Stories Widget - Instagram-like stories for technicians
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
      // Sample stories for demonstration
      _stories = [
        Story(
          id: '1',
          techId: 'tech1',
          techName: 'محمد علي',
          techImg: '',
          media: 'https://picsum.photos/400/600?random=1',
          type: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Story(
          id: '2',
          techId: 'tech2',
          techName: 'أحمد حسن',
          techImg: '',
          media: 'https://picsum.photos/400/600?random=2',
          type: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        Story(
          id: '3',
          techId: 'tech3',
          techName: 'علي محمود',
          techImg: '',
          media: 'https://picsum.photos/400/600?random=3',
          type: 'image',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
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

  Future<void> _addStory() async {
    if (widget.userRole != 'tech') return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // TODO: Upload to Firebase Storage and add to Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة القصة بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding story: $e');
    }
  }

  void _viewStory(Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewerScreen(
          stories: _stories.where((s) => s.techId == story.techId).toList(),
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
        height: 100,
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
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: groupedStories.length + (widget.userRole == 'tech' ? 1 : 0),
        itemBuilder: (context, index) {
          // Add story button for technicians
          if (widget.userRole == 'tech' && index == 0) {
            return _buildAddStoryButton(isDark);
          }

          final adjustedIndex = widget.userRole == 'tech' ? index - 1 : index;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _addStory,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'إضافة قصة',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStoryItem(Story story, bool isDark, int storyCount) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _viewStory(story),
            child: Container(
              width: 68,
              height: 68,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          child: Center(
                            child: Text(
                              story.techName[0],
                              style: TextStyle(
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
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 70,
            child: Text(
              story.techName,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildSkeletonItem(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white10 : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 50,
            height: 12,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade300,
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

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapUp: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.localPosition.dx < screenWidth / 3) {
              _previousStory();
            } else {
              _nextStory();
            }
          },
          child: Stack(
            children: [
              // Story content
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.stories.length,
                itemBuilder: (context, index) {
                  final story = widget.stories[index];
                  return CachedNetworkImage(
                    imageUrl: story.media,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  );
                },
              ),

              // Progress bars
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                right: 8,
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

              // Header with user info
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      child: Text(
                        widget.stories[_currentIndex].techName[0],
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stories[_currentIndex].techName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatTime(widget.stories[_currentIndex].timestamp),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
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
