import 'package:flutter/material.dart';

class BreathingExerciseWidget extends StatefulWidget {
  final ColorScheme colorScheme ;

  const BreathingExerciseWidget({super.key, required this.colorScheme});

  @override
  BreathingExerciseWidgetState createState() => BreathingExerciseWidgetState();
}

class BreathingExerciseWidgetState extends State<BreathingExerciseWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final int inhaleDuration = 4000;  // 4 seconds
  final int holdDuration = 7000;    // 7 seconds
  final int exhaleDuration = 8000;  // 8 seconds

  @override
  void initState() {
    super.initState();

    final totalDuration = inhaleDuration + holdDuration + exhaleDuration;

    _controller = AnimationController(
      duration: Duration(milliseconds: totalDuration),
      vsync: this,
    )..repeat();

    _animation = TweenSequence([
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: inhaleDuration.toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween(1.0),
        weight: holdDuration.toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)),
        weight: exhaleDuration.toDouble(),
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getBreathingPhase() {
    final total = inhaleDuration + holdDuration + exhaleDuration;
    final currentTime = (_controller.value * total).toInt();

    if (currentTime < inhaleDuration) return "Breathe In";
    if (currentTime < inhaleDuration + holdDuration) return "Hold";
    return "Breathe Out";
  }

  int _getRemainingSeconds() {
    final total = inhaleDuration + holdDuration + exhaleDuration;
    final currentTime = (_controller.value * total).toInt();

    if (currentTime < inhaleDuration) {
      return ((inhaleDuration - currentTime) / 1000).ceil();
    } else if (currentTime < inhaleDuration + holdDuration) {
      return ((inhaleDuration + holdDuration - currentTime) / 1000).ceil();
    } else {
      return ((total - currentTime) / 1000).ceil();
    }
  }

  @override
Widget build(BuildContext context) {
  final Color primaryColor = widget.colorScheme.primary;
  final Color textColor = widget.colorScheme.onSurface;

  return AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
      final phase = _getBreathingPhase();
      final seconds = _getRemainingSeconds();

      return Column(
        children: [
          const SizedBox(height: 24),

          Text(
            "4-7-8 Breathing",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: textColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Inhale • Hold • Exhale",
            style: TextStyle(
              fontSize: 16,
              color: textColor.withValues(alpha: 0.75),
            ),
          ),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              "$phase for $seconds s",
              key: ValueKey(phase),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 THIS FIXES OVERFLOW
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxSize =
                      constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;

                  final circleBaseSize = maxSize * 0.75;

                  return Container(
                    width: circleBaseSize * _animation.value,
                    height: circleBaseSize * _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.6),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Repeat this for 4 breath cycles.",
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 16),
        ],
      );
    },
  );
}
}