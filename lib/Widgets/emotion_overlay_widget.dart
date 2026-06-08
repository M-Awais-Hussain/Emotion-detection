import 'package:flutter/material.dart';

class EmotionOverlayWidget extends StatelessWidget {
  final String emotion;
  final bool isDetecting;
  final bool showOverlay;

  const EmotionOverlayWidget({
    super.key,
    required this.emotion,
    this.isDetecting = false,
    this.showOverlay = true,
  });

  // Emotion data mapping
  static const Map<String, Map<String, dynamic>> emotionData = {
    'happy': {
      'emoji': '😄',
      'color': Colors.amber,
      'backgroundColor': Color(0xFFFFF8E1),
    },
    'sad': {
      'emoji': '😢',
      'color': Colors.blue,
      'backgroundColor': Color(0xFFE3F2FD),
    },
    'angry': {
      'emoji': '😠',
      'color': Colors.red,
      'backgroundColor': Color(0xFFFFEBEE),
    },
    'neutral': {
      'emoji': '😐',
      'color': Colors.blueGrey,
      'backgroundColor': Color(0xFFF5F7FA),
    },
    'fear': {
      'emoji': '😨',
      'color': Colors.deepPurple,
      'backgroundColor': Color(0xFFEDE7F6),
    },
    'disgust': {
      'emoji': '🤢',
      'color': Colors.green,
      'backgroundColor': Color(0xFFE8F5E9),
    },
    'surprise': {
      'emoji': '😲',
      'color': Colors.pink,
      'backgroundColor': Color(0xFFFCE4EC),
    },
    'detecting...': {
      'emoji': '🔍',
      'color': Colors.grey,
      'backgroundColor': Color(0xFFF5F5F5),
    },
    'error': {
      'emoji': '❌',
      'color': Colors.grey,
      'backgroundColor': Color(0xFFF5F5F5),
    },
  };

  @override
  Widget build(BuildContext context) {
    if (!showOverlay) return const SizedBox.shrink();

    final emotionInfo = emotionData[emotion.toLowerCase()] ?? emotionData['detecting...']!;

    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: (emotionInfo['backgroundColor'] as Color).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: (emotionInfo['color'] as Color).withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emotion emoji
            Text(
              emotionInfo['emoji'],
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            
            // Emotion text and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getEmotionDisplayText(emotion),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: emotionInfo['color'].shade700,
                  ),
                ),
                if (isDetecting)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            emotionInfo['color'].shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Analyzing...',
                        style: TextStyle(
                          fontSize: 12,
                          color: emotionInfo['color'].shade600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEmotionDisplayText(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'detecting...':
        return 'Detecting Emotion';
      case 'error':
        return 'Detection Error';
      default:
        return emotion[0].toUpperCase() + emotion.substring(1);
    }
  }
}

