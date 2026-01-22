import 'package:flutter/material.dart';

/// Custom Page Route with Slide Transition
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = AxisDirection.left,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case AxisDirection.up:
                begin = const Offset(0.0, 1.0);
                break;
              case AxisDirection.down:
                begin = const Offset(0.0, -1.0);
                break;
              case AxisDirection.left:
                begin = const Offset(1.0, 0.0);
                break;
              case AxisDirection.right:
                begin = const Offset(-1.0, 0.0);
                break;
            }
            
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}

/// Fade Page Route
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// Scale and Fade Page Route
class ScaleFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleFadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.8;
            const end = 1.0;
            const curve = Curves.easeInOutCubic;

            var scaleTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

/// Bottom Sheet Slide Route
class BottomSheetPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  BottomSheetPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          opaque: false,
          barrierColor: Colors.black54,
        );
}

/// Extension for easy navigation with custom transitions
extension NavigationExtension on BuildContext {
  /// Navigate with slide transition
  Future<T?> pushSlide<T>(Widget page, {AxisDirection direction = AxisDirection.left}) {
    return Navigator.of(this).push<T>(
      SlidePageRoute<T>(page: page, direction: direction),
    );
  }

  /// Navigate with fade transition
  Future<T?> pushFade<T>(Widget page) {
    return Navigator.of(this).push<T>(
      FadePageRoute<T>(page: page),
    );
  }

  /// Navigate with scale and fade transition
  Future<T?> pushScaleFade<T>(Widget page) {
    return Navigator.of(this).push<T>(
      ScaleFadePageRoute<T>(page: page),
    );
  }

  /// Navigate with bottom sheet style transition
  Future<T?> pushBottomSheet<T>(Widget page) {
    return Navigator.of(this).push<T>(
      BottomSheetPageRoute<T>(page: page),
    );
  }
}
