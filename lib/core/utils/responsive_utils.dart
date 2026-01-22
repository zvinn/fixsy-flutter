import 'package:flutter/material.dart';

/// Responsive breakpoints following Material Design guidelines
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Utility class for responsive design
class ResponsiveUtils {
  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final bool isMobile;
  late final bool isTablet;
  late final bool isDesktop;

  ResponsiveUtils(this.context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    isMobile = screenWidth < ResponsiveBreakpoints.mobile;
    isTablet = screenWidth >= ResponsiveBreakpoints.mobile && 
               screenWidth < ResponsiveBreakpoints.tablet;
    isDesktop = screenWidth >= ResponsiveBreakpoints.tablet;
  }

  /// Returns different values based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Grid cross axis count for services/items grid
  int get gridCrossAxisCount {
    if (screenWidth >= ResponsiveBreakpoints.desktop) return 4;
    if (screenWidth >= ResponsiveBreakpoints.tablet) return 3;
    if (screenWidth >= ResponsiveBreakpoints.mobile) return 2;
    return 2;
  }

  /// Card aspect ratio based on screen size
  double get cardAspectRatio {
    if (isDesktop) return 0.85;
    if (isTablet) return 0.8;
    return 0.75;
  }

  /// Horizontal padding based on screen size
  double get horizontalPadding {
    if (isDesktop) return 32.0;
    if (isTablet) return 24.0;
    return 16.0;
  }

  /// Font scale factor for responsive typography
  double get fontScale {
    if (isDesktop) return 1.1;
    if (isTablet) return 1.05;
    return 1.0;
  }

  /// Bottom sheet max width for larger screens
  double get bottomSheetMaxWidth {
    if (isDesktop) return 600;
    if (isTablet) return 500;
    return double.infinity;
  }

  /// Dialog max width
  double get dialogMaxWidth {
    if (isDesktop) return 500;
    if (isTablet) return 450;
    return screenWidth * 0.9;
  }
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, ResponsiveUtils responsive) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveUtils(context));
  }
}

/// Extension for easy responsive access
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}
