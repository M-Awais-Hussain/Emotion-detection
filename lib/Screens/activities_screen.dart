import 'package:flutter/material.dart';
import 'dart:ui';

import '../Widgets/MoodBoosterWidgets/angry/anger_journal_widget.dart';
import '../Widgets/MoodBoosterWidgets/angry/breathing_exercise_widget.dart';
import '../Widgets/MoodBoosterWidgets/angry/physical_activities_screen.dart';
import '../Widgets/MoodBoosterWidgets/fear/grounding_exercise_widget.dart';
import '../Widgets/MoodBoosterWidgets/neutral/to_do_list.dart';
import '../Widgets/MoodBoosterWidgets/neutral/what_went_well.dart';
import '../Widgets/MoodBoosterWidgets/sad/gratitude_journal_widget.dart';
import '../Widgets/MoodBoosterWidgets/sad/happy_music_playlist.dart';
import '../Widgets/MoodBoosterWidgets/sad/happy_youtube_playlist.dart';
import '../Widgets/MoodBoosterWidgets/sad/letter_yourself_widget.dart';

// Import your activity screens here
// import 'activities/sad/gratitude_journal_widget.dart';
// import 'activities/sad/letter_yourself.dart';
// import 'activities/angry/anger_journal_widget.dart';
// import 'activities/angry/breathing_exercise_widget.dart';
// import 'activities/neutral/to_do_list.dart';
// import 'activities/neutral/what_went_well_activity.dart';
// import 'activities/fear/grounding_exercise_widget.dart';

class ActivitiesPage extends StatelessWidget {
  ActivitiesPage({super.key});

  // Define activities for each emotion based on your folder structure
  final Map<String, List<Map<String, dynamic>>> emotionActivities = {
    'Sad': [
      {
        'name': 'Gratitude Journal',
        'icon': Icons.favorite,
        'screen': 'GratitudeJournalWidget',
        'type': 'screen'
      },
      {
        'name': 'Letter to Yourself',
        'icon': Icons.mail,
        'screen': 'LetterYourself',
        'type': 'screen'
      },
    ],
    'Angry': [
      {
        'name': 'Anger Journal',
        'icon': Icons.book,
        'screen': 'AngerJournalWidget',
        'type': 'screen'
      },
      {
        'name': 'Breathing Exercise',
        'icon': Icons.air,
        'screen': 'BreathingExerciseWidget',
        'type': 'screen'
      },
      {
        'name': 'Physical Activities',
        'icon': Icons.fitness_center,
        'screen': 'showAngerExercisesDialog',
        'type': 'popup'
      },
    ],
    'Neutral': [
      {
        'name': 'To-Do List',
        'icon': Icons.checklist,
        'screen': 'ToDoList',
        'type': 'screen'
      },
      {
        'name': 'What Went Well',
        'icon': Icons.emoji_emotions,
        'screen': 'WhatWentWellActivity',
        'type': 'screen'
      },
    ],
    'Fear': [
      {
        'name': 'Grounding Exercise',
        'icon': Icons.spa,
        'screen': 'GroundingExerciseWidget',
        'type': 'screen'
      },
    ],
    'Disgust': [
      {
        'name': 'Breathing Exercise',
        'icon': Icons.air,
        'screen': 'BreathingExerciseWidget',
        'type': 'screen'
      },
    ],
    'Surprise': [
      {
        'name': 'To-Do List',
        'icon': Icons.checklist,
        'screen': 'ToDoList',
        'type': 'screen'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: emotionActivities.entries.map((entry) {
                return _buildEmotionSection(
                  context,
                  emotion: entry.key,
                  activities: entry.value,
                );
              }).toList(),

            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionSection(
      BuildContext context, {
        required String emotion,
        required List<Map<String, dynamic>> activities,
      }) {
    Color emotionColor = Color.fromARGB(255, 0, 31, 84);

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Emotion Header with blur effect
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 179, 201, 239),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: emotionColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getEmotionIcon(emotion),
                      color: emotionColor,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      emotion,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: emotionColor.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: emotionColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${activities.length} ${activities.length == 1 ? 'Activity' : 'Activities'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: emotionColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          // Activities List
          ...activities.map((activity) {
            return _buildActivityCard(
              context,
              activityName: activity['name'],
              icon: activity['icon'],
              screenName: activity['screen'],
              navigationType: activity['type'] ?? 'screen',
              emotionColor: emotionColor,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      BuildContext context, {
        required String activityName,
        required IconData icon,
        required String screenName,
        required String navigationType,
        required Color emotionColor,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _handleNavigation(context, screenName, navigationType);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: emotionColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: emotionColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    activityName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation handler based on type
  void _handleNavigation(BuildContext context, String screenName, String type) {
    debugPrint("Navigating to: $screenName with type: $type");

    switch (type) {
      case 'screen':
        _navigateToScreen(context, screenName);
        break;
      case 'popup':
        if (screenName == 'showHappyMusicPlaylistPopup') {
          showHappyMusicPlaylistPopup(context);
        } else if (screenName == 'showHappyYoutubePlaylistPopup') {
          showHappyYoutubePlaylistPopup(context);
        }else if (screenName == 'showAngerExercisesDialog') {
          showAngerExercisesDialog(context);
        }
        break;
      default:
        _navigateToScreen(context, screenName);
    }
  }

  // Navigate to full screen widget
  void _navigateToScreen(BuildContext context, String screenName) {
    Widget? screen = _getScreenWidget(screenName);

    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    } else {
      debugPrint("Screen not found: $screenName");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Screen not implemented yet: $screenName')),
      );
    }
  }

  // Get screen widget based on name
  Widget? _getScreenWidget(String screenName) {
    switch (screenName) {
      case 'GratitudeJournalWidget':
      return Scaffold(
        appBar: AppBar(title: Text("Gratitude Journal")),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: GratitudeJournalWidget(
              colorScheme: ColorScheme(
                  primary: Color(0xFF2196F3),
                  secondary: Color(0xFF64B5F6),
                  surface: Colors.white,
                  error: Colors.red,
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                  onSurface: Colors.black,
                  onError: Colors.white,
                  brightness: Brightness.light),
            ),
          ),
        ),
      );
      case 'LetterYourself':
        return Scaffold(
          appBar: AppBar(title: Text("Gratitude Journal")),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: LetterYourself(),
            ),
          ),
        );
      case 'AngerJournalWidget':
        return Scaffold(
          appBar: AppBar(title: Text("Gratitude Journal")),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: AngerJournalWidget(),
            ),
          ),
        );
      case 'BreathingExerciseWidget':
        return Scaffold(
          appBar: AppBar(title: Text("Gratitude Journal")),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: BreathingExerciseWidget(
                colorScheme: ColorScheme(
                    primary: Color(0xFF2196F3),
                    secondary: Color(0xFF64B5F6),
                    surface: Colors.white,
                    error: Colors.red,
                    onPrimary: Colors.white,
                    onSecondary: Colors.white,
                    onSurface: Colors.black,
                    onError: Colors.white,
                    brightness: Brightness.light),
              ),
            ),
          ),
        );
      case 'ToDoList':
        return Scaffold(
          appBar: AppBar(title: Text("Gratitude Journal")),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: ToDoList(),
            ),
          ),
        );
      case 'WhatWentWellActivity':
        return Scaffold(
          appBar: AppBar(title: Text("Gratitude Journal")),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: WhatWentWellActivity(),
            ),
          ),
        );
      case 'GroundingExerciseWidget':
        return Scaffold(
          appBar: AppBar(title: Text("Gratitude Journal")),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: GroundingExerciseWidget(),
            ),
          ),
        );
      default:
        return null;
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'fear':
        return Icons.sentiment_dissatisfied;
      case 'disgust':
        return Icons.sick;
      case 'surprise':
        return Icons.sentiment_very_satisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'happy':
        return Icons.sentiment_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
