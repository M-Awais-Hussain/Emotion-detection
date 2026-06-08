import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A widget that responds to detected emotional states with appropriate UI
/// and therapeutic interventions based on psychological principles.
class MoodResponseWidget extends StatefulWidget {
  final String detectedMood;

  const MoodResponseWidget({
    super.key,
    required this.detectedMood,
  });

  @override
  MoodResponseWidgetState createState() => MoodResponseWidgetState();
}

class MoodResponseWidgetState extends State<MoodResponseWidget> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mood-specific color schemes based on color psychology
  final Map<String, ColorScheme> _moodColorSchemes = {
    'sad': ColorScheme(
      primary: Color(0xFF5DADE2),
      secondary: Color(0xFFF7DC6F),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'angry': ColorScheme(
      primary: Color(0xFFE74C3C),
      secondary: Color(0xFF58D68D),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'fear': ColorScheme(
      primary: Color(0xFF7E57C2),
      secondary: Color(0xFFD1C4E9),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'disgust': ColorScheme(
      primary: Color(0xFF66BB6A),
      secondary: Color(0xFFC8E6C9),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'surprise': ColorScheme(
      primary: Color(0xFFEC407A),
      secondary: Color(0xFFF8BBD0),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'happy': ColorScheme(
      primary: Color(0xFF2ECC71),
      secondary: Color(0xFFF39C12),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    'neutral': ColorScheme(
      primary: Color(0xFF78909C),
      secondary: Color(0xFFB0BEC5),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
  };

  // Evidence-based therapeutic messages and activities
  final Map<String, Map<String, dynamic>> _moodInterventions = {
    'sad': {
      'message': 'It\'s okay to feel sad sometimes. Let\'s try something to help.',
      'activity': 'Gratitude Journaling',
      'description': 'Write down three things you\'re grateful for today. Gratitude practice has been shown to improve mood.',
      'icon': Icons.import_contacts,
    },
    'angry': {
      'message': 'Take a deep breath. Let\'s calm your mind together.',
      'activity': 'Breathing Exercise',
      'description': 'Follow the circle to regulate your breathing. Deep breathing activates the parasympathetic nervous system.',
      'icon': Icons.air,
    },
    'fear': {
      'message': 'You\'re safe right now. Let\'s ground yourself in the present.',
      'activity': '5-4-3-2-1 Grounding',
      'description': 'Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, and 1 you taste. Grounding techniques reduce anxiety.',
      'icon': Icons.anchor,
    },
    'disgust': {
      'message': 'Take a moment to reset. Shift to something positive.',
      'activity': 'Cognitive Reframing',
      'description': 'Identify one small positive aspect in your current situation.',
      'icon': Icons.cleaning_services,
    },
    'surprise': {
      'message': 'An unexpected moment! Embrace new experiences.',
      'activity': 'Centering Pause',
      'description': 'Take a moment to process this new information mindfully.',
      'icon': Icons.lightbulb,
    },
    'happy': {
      'message': 'Your happiness is contagious! Let\'s build on this positive energy.',
      'activity': 'Positive Reinforcement',
      'description': 'Write down what made you happy today to reinforce positive neural pathways.',
      'icon': Icons.emoji_emotions,
    },
    'neutral': {
      'message': 'You\'re feeling balanced. Let\'s maintain this peaceful state.',
      'activity': 'Mindful Observation',
      'description': 'Take 2 minutes to observe your surroundings without judgment. Notice colors, textures, and sounds. Mindfulness preserves emotional equilibrium.',
      'icon': Icons.self_improvement,
    },
  };

  @override
  void initState() {
    super.initState();

    // Animation setup for smooth entrance
    animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    ));

    // Start animation after build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      animationController.forward();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = _moodColorSchemes[widget.detectedMood.toLowerCase()] ??
        _moodColorSchemes['happy']!;
    final intervention = _moodInterventions[widget.detectedMood.toLowerCase()] ??
        _moodInterventions['happy']!;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),

          // 1st Card
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Mood header with icon
              Row(
                children: [
                  Icon(
                    intervention['icon'],
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'You seem ${widget.detectedMood[0].toUpperCase() + widget.detectedMood.substring(1)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Emotional validation message
              Text(
                intervention['message'],
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// /// Custom animated button for activities with built-in micro-interactions
// class _ActivityButton extends StatefulWidget {
//   final ColorScheme colorScheme;
//   final VoidCallback onPressed;
//
//   const _ActivityButton({
//     required this.colorScheme,
//     required this.onPressed,
//   });
//
//   @override
//   ActivityButtonState createState() => ActivityButtonState();
// }
//
// class ActivityButtonState extends State<_ActivityButton> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _controller.forward(),
//       onTapUp: (_) {
//         _controller.reverse();
//         widget.onPressed();
//       },
//       onTapCancel: () => _controller.reverse(),
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//           decoration: BoxDecoration(
//             color: widget.colorScheme.primary,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: widget.colorScheme.primary.withValues(alpha: 0.3),
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               'Start Activity',
//               style: TextStyle(
//                 color: widget.colorScheme.onPrimary,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }