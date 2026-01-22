import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Skeleton Loading Widget for various use cases
class SkeletonLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade200,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    ).animate(onPlay: (c) => c.repeat())
      .shimmer(
        duration: 1200.ms,
        color: isDark ? Colors.white24 : Colors.grey.shade300,
      );
  }
}

/// Card Skeleton - for loading cards
class CardSkeleton extends StatelessWidget {
  final bool showImage;
  final bool showAvatar;
  final int lines;
  final double height;

  const CardSkeleton({
    super.key,
    this.showImage = false,
    this.showAvatar = false,
    this.lines = 3,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          if (showImage)
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: SkeletonLoading(
                width: 80,
                height: 80,
                borderRadius: 12,
              ),
            ),
          if (showAvatar)
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: SkeletonLoading(
                width: 50,
                height: 50,
                isCircle: true,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(lines, (index) {
                final widthFactor = index == 0 
                    ? 0.7 
                    : index == lines - 1 
                        ? 0.4 
                        : 0.9;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < lines - 1 ? 12 : 0),
                  child: FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: SkeletonLoading(
                      height: index == 0 ? 18 : 14,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// List Skeleton - for loading lists
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final bool showAvatar;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 72,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: CardSkeleton(
            showAvatar: showAvatar,
            height: itemHeight,
            lines: 2,
          ),
        ).animate().fadeIn(delay: (100 * index).ms);
      },
    );
  }
}

/// Service Card Skeleton
class ServiceCardSkeleton extends StatelessWidget {
  const ServiceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoading(
            width: 48,
            height: 48,
            borderRadius: 12,
          ),
          const Spacer(),
          const SkeletonLoading(
            width: 80,
            height: 16,
          ),
          const SizedBox(height: 8),
          const SkeletonLoading(
            width: 60,
            height: 12,
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms);
  }
}

/// Booking Card Skeleton
class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
            children: [
              const SkeletonLoading(
                width: 50,
                height: 50,
                isCircle: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoading(width: 120, height: 16),
                    SizedBox(height: 8),
                    SkeletonLoading(width: 80, height: 12),
                  ],
                ),
              ),
              const SkeletonLoading(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonLoading(height: 14),
          const SizedBox(height: 8),
          const SkeletonLoading(width: 150, height: 14),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms);
  }
}

/// Profile Skeleton
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          const Center(
            child: SkeletonLoading(
              width: 100,
              height: 100,
              isCircle: true,
            ),
          ),
          const SizedBox(height: 16),
          // Name
          const Center(
            child: SkeletonLoading(width: 150, height: 24),
          ),
          const SizedBox(height: 8),
          // Email
          const Center(
            child: SkeletonLoading(width: 200, height: 14),
          ),
          const SizedBox(height: 32),
          // Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(4, (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    SkeletonLoading(width: 40, height: 40, borderRadius: 8),
                    const SizedBox(width: 16),
                    Expanded(child: SkeletonLoading(height: 16)),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
