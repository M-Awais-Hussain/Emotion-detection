import 'package:flutter/material.dart';
import 'dart:math' as math;

class SuccessDialog extends StatefulWidget {
  const SuccessDialog({super.key});

  @override
  SuccessDialogState createState() => SuccessDialogState();
}

class SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if(mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(150, 150),
              painter: CheckmarkPainter(_animation),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Email Sent Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final Animation<double> animation;

  CheckmarkPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final Paint checkPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final double progress = animation.value;

    // Draw circle
    if (progress < 0.5) {
      final double circleProgress = math.min(1.0, progress * 2);
      final double sweepAngle = 2 * math.pi * circleProgress;
      canvas.drawArc(
          Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 4),
          -math.pi / 2,
          sweepAngle,
          false,
          circlePaint
      );
    } else {
      canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 4, circlePaint);
    }

    // Draw checkmark
    if (progress > 0.5) {
      final Path path = Path();
      final double checkProgress = (progress - 0.5) * 2;

      path.moveTo(size.width * 0.25, size.height * 0.5);

      if (checkProgress < 0.5) {
        final double firstLineProgress = checkProgress * 2;
        path.lineTo(
            size.width * (0.25 + 0.2 * firstLineProgress),
            size.height * (0.5 + 0.2 * firstLineProgress)
        );
      } else {
        path.lineTo(size.width * 0.45, size.height * 0.7);
        final double secondLineProgress = (checkProgress - 0.5) * 2;
        path.lineTo(
            size.width * (0.45 + 0.3 * secondLineProgress),
            size.height * (0.7 - 0.4 * secondLineProgress)
        );
      }
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}