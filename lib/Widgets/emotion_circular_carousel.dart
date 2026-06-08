import 'package:flutter/material.dart';
import 'dart:math' as math;

class EmotionCircularCarousel extends StatefulWidget {
  final ValueChanged<int>? onSelected;

  const EmotionCircularCarousel({super.key, this.onSelected});

  @override
  EmotionCircularCarouselState createState() => EmotionCircularCarouselState();
}

class EmotionCircularCarouselState extends State<EmotionCircularCarousel> with TickerProviderStateMixin {
  final List<Widget> emojis = [
    const Text('😐', style: TextStyle(fontSize: 35)),
    const Text('😞', style: TextStyle(fontSize: 35)),
    const Text('😄', style: TextStyle(fontSize: 35)),
    const Text('😠', style: TextStyle(fontSize: 35)),
    const Text('😨', style: TextStyle(fontSize: 35)),
    const Text('🤢', style: TextStyle(fontSize: 35)),
    const Text('😲', style: TextStyle(fontSize: 35)),
  ];

  final List<String> emotionLabels = ["Neutral", "Sad", "Happy", "Angry", "Fear", "Disgust", "Surprise"];

  double rotation = 0.0; // current rotation (radians)
  late final double spacing; // angle step between items
  late final int midIndex;
  late final AnimationController _animController;
  Animation<double>? _rotationAnim;

  // Enhanced smooth sliding parameters
  double radius = 350.0;
  double dragSensitivity = 380.0;
 

  // Mood-based background colors
  final Map<int, Color> moodBackgroundColors = {
    0: const Color(0xFFF5F7FA), // Neutral - Light grey
    1: const Color(0xFFE3F2FD), // Sad - Light blue
    2: const Color(0xFFFFF8E1), // Happy - Light yellow
    3: const Color(0xFFFFEBEE), // Angry - Light red
    4: const Color(0xFFEDE7F6), // Fear - Light deep purple
    5: const Color(0xFFE8F5E9), // Disgust - Light green
    6: const Color(0xFFFCE4EC), // Surprise - Light pink
  };

  @override
  void initState() {
    super.initState();
    final n = emojis.length;
    spacing = math.pi / (n+3); // symmetric arc around angle 0
    midIndex = (n - 1) ~/ 2;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Smooth snap duration
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Smooth snap to index
  void _snapToIndex(int index) {
    final currentAngleOfIndex = (index - midIndex) * spacing + rotation;
    final targetRotation = rotation - currentAngleOfIndex;
    _rotationAnim?.removeListener(_animListener);
    _rotationAnim = Tween<double>(begin: rotation, end: targetRotation)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic))
      ..addListener(_animListener);
    _animController.forward(from: 0);

    // Notify parent
    widget.onSelected?.call(index);
  }

  void _animListener() => setState(() => rotation = _rotationAnim!.value);

  // Find index whose angle is closest to 0 (used on drag end)
  int _nearestIndex() {
    final n = emojis.length;
    int best = 0;
    double bestAbs = double.infinity;
    for (int i = 0; i < n; i++) {
      final angle = (i - midIndex) * spacing + rotation;
      final a = angle.abs();
      if (a < bestAbs) {
        bestAbs = a;
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = 470.0;
    final n = emojis.length;
    final nearest = _nearestIndex();

    // Build a list of layout info for each item
    final List<_ItemInfo> infos = List.generate(n, (i) {
      final angle = (i - midIndex) * spacing + rotation;
      final x = centerX + radius * math.sin(angle);
      final y = centerY - radius * math.cos(angle);
      final depth = math.cos(angle);
      final scale = (0.7 + 0.5 * (depth + 1) / 2).clamp(0.5, 1.5);
      final opacity = (0.5 + 0.5 * (depth + 1) / 2).clamp(0.4, 1.0);
      return _ItemInfo(index: i, angle: angle, x: x, y: y, depth: depth, scale: scale, opacity: opacity);
    });

    // Sort by depth for proper layering
    infos.sort((a, b) => a.depth.compareTo(b.depth));

    return Container(
      color: moodBackgroundColors[nearest] ?? moodBackgroundColors[2]!,
      child: SizedBox(
        width: size.width,
        height: 220,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            setState(() {
              rotation += details.delta.dx / dragSensitivity;
            });
          },
          onHorizontalDragEnd: (details) {
            final idx = _nearestIndex();
            _snapToIndex(idx);
          },
          child: Stack(
            children: [
              // Enhanced heading
              Positioned(
                top: 28,
                left: 0,
                right: 0,
                child: Text(
                  'How are you feeling today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getMoodTextColor(nearest),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Emoji items
              for (final info in infos)
                Positioned(
                  left: (info.x - 36 * info.scale) + 13,
                  top: info.y - 36 * info.scale,
                  child: GestureDetector(
                    onTap: () => _snapToIndex(info.index),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateZ(info.angle * 0.3),
                      child: Transform.scale(
                        scale: info.scale,
                        child: Opacity(
                          opacity: info.opacity,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: info.index == nearest ? 70 : 60,
                            height: info.index == nearest ? 70 : 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: info.index == nearest
                                  ? _getMoodGradient(nearest)
                                  : LinearGradient(
                                  colors: [Colors.grey.shade700, Colors.grey.shade600]
                              ),
                              boxShadow: [
                                if (info.index == nearest)
                                  BoxShadow(
                                    color: _getMoodShadowColor(nearest),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: emojis[info.index],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Enhanced emotion label
              Positioned(
                top: 170,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMoodAccentColor(nearest),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      emotionLabels[nearest],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for mood-based styling
  Color _getMoodTextColor(int moodIndex) {
    switch (moodIndex) {
      case 0: return Colors.blueGrey.shade700; // Neutral
      case 1: return Colors.blue.shade800;     // Sad
      case 2: return Colors.orange.shade800;   // Happy
      case 3: return Colors.red.shade800;      // Angry
      case 4: return Colors.deepPurple.shade800; // Fear
      case 5: return Colors.green.shade800;    // Disgust
      case 6: return Colors.pink.shade800;     // Surprise
      default: return Colors.black87;
    }
  }

  LinearGradient _getMoodGradient(int moodIndex) {
    switch (moodIndex) {
      case 0: // Neutral
        return LinearGradient(
          colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 1: // Sad
        return LinearGradient(
          colors: [Colors.blue.shade300, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2: // Happy
        return LinearGradient(
          colors: [Colors.yellow.shade300, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3: // Angry
        return LinearGradient(
          colors: [Colors.red.shade300, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 4: // Fear
        return LinearGradient(
          colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 5: // Disgust
        return LinearGradient(
          colors: [Colors.green.shade300, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 6: // Surprise
        return LinearGradient(
          colors: [Colors.pink.shade300, Colors.pink.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade600],
        );
    }
  }

  Color _getMoodShadowColor(int moodIndex) {
    switch (moodIndex) {
      case 0: return Colors.blueGrey.withValues(alpha: 0.4);
      case 1: return Colors.blue.withValues(alpha: 0.4);
      case 2: return Colors.orange.withValues(alpha: 0.4);
      case 3: return Colors.red.withValues(alpha: 0.4);
      case 4: return Colors.deepPurple.withValues(alpha: 0.4);
      case 5: return Colors.green.withValues(alpha: 0.4);
      case 6: return Colors.pink.withValues(alpha: 0.4);
      default: return Colors.grey.withValues(alpha: 0.4);
    }
  }

  Color _getMoodAccentColor(int moodIndex) {
    switch (moodIndex) {
      case 0: return Colors.blueGrey.shade600;
      case 1: return Colors.blue.shade600;
      case 2: return Colors.orange.shade600;
      case 3: return Colors.red.shade600;
      case 4: return Colors.deepPurple.shade600;
      case 5: return Colors.green.shade600;
      case 6: return Colors.pink.shade600;
      default: return Colors.grey.shade600;
    }
  }
}

class _ItemInfo {
  final int index;
  final double angle;
  final double x;
  final double y;
  final double depth;
  final double scale;
  final double opacity;
  _ItemInfo({
    required this.index,
    required this.angle,
    required this.x,
    required this.y,
    required this.depth,
    required this.scale,
    required this.opacity,
  });
}