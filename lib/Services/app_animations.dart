import 'package:flutter/material.dart';

/// Centralized animation utilities for consistent motion design throughout the app.
/// All navigation and UI transitions must use these standardized durations and curves.
class AppAnimations {
  // Standard animation durations
  static const Duration splashDuration = Duration(milliseconds: 3000);
  static const Duration quickTransition = Duration(milliseconds: 300);
  static const Duration mediumTransition = Duration(milliseconds: 500);
  static const Duration slowTransition = Duration(milliseconds: 800);
  static const Duration fadeTransition = Duration(milliseconds: 600);

  // Animation curves for different purposes
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve sharpCurve = Curves.easeInOutQuart;

  // Splash screen specific animations
  static const Duration splashFadeIn = Duration(milliseconds: 800);
  static const Duration splashScaleUp = Duration(milliseconds: 1200);
  static const Duration splashSlideUp = Duration(milliseconds: 1000);
  static const Duration splashFadeOut = Duration(milliseconds: 600);

  // Common animation combinations
  static AnimationController createSplashController({
    required TickerProvider vsync,
    Duration? duration,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration ?? splashDuration,
    );
  }

  static Animation<double> createFadeAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = smoothCurve,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    double begin = 0.8,
    double end = 1.0,
    Curve curve = enterCurve,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static Animation<Offset> createSlideAnimation({
    required AnimationController controller,
    Offset begin = const Offset(0, 0.3),
    Offset end = Offset.zero,
    Curve curve = enterCurve,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  // Page transition builders
  static PageRouteBuilder createFadePageRoute({
    required Widget page,
    Duration? duration,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: duration ?? fadeTransition,
    );
  }

  static PageRouteBuilder createSlidePageRoute({
    required Widget page,
    Offset begin = const Offset(1.0, 0.0),
    Duration? duration,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: begin, end: Offset.zero);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: enterCurve),
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration ?? mediumTransition,
    );
  }
}