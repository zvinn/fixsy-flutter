import 'package:flutter/material.dart';

/// Animated Gradient Card
/// Beautiful card with gradient background and animations
class AnimatedGradientCard extends StatefulWidget {
  final Widget child;
  final List<Color> gradientColors;
  final Duration animationDuration;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const AnimatedGradientCard({
    Key? key,
    required this.child,
    required this.gradientColors,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedGradientCard> createState() => _AnimatedGradientCardState();
}

class _AnimatedGradientCardState extends State<AnimatedGradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Shimmer Loading Effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.child,
    required this.isLoading,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Glass Morphism Container
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsets padding;
  final Border? border;

  const GlassMorphismContainer({
    Key? key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(20),
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ??
              Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Animated Icon Button
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const AnimatedIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  }) : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: IconButton(
          icon: Icon(widget.icon),
          onPressed: widget.onPressed,
          color: widget.color,
          iconSize: widget.size,
          tooltip: widget.tooltip,
        ),
      ),
    );
  }
}

/// Custom Badge
class CustomBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;

  const CustomBadge({
    Key? key,
    required this.text,
    this.backgroundColor = const Color(0xFFEF4444),
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Skeleton Loader
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
