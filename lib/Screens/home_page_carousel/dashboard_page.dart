import 'package:emotioneye/Screens/exercise_detail_screen.dart';
import 'package:emotioneye/Widgets/MoodBoosterWidgets/angry/breathing_exercise_widget.dart';
import 'package:emotioneye/Widgets/activity_card.dart';
import 'package:emotioneye/Widgets/emotion_circular_carousel.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

import '../../Widgets/MoodBoosterWidgets/sad/gratitude_journal_widget.dart';
import '../../model/exercise_model.dart';
import '../games_page.dart';
import '../goal_setting.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedEmotion = 2;

  String _findEmotion(emotionIndex) {
    switch (emotionIndex) {
      case 0:
        return "Neutral";
      case 1:
        return "Sad";
      case 2:
        return "Happy";
      case 3:
        return "Angry";
      case 4:
        return "Fear";
      case 5:
        return "Disgust";
      case 6:
        return "Surprise";
      default:
        return "Happy";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Enhanced emotion carousel container
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300, // very light background
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), // soft shadow (blur effect)
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: EmotionCircularCarousel(
                  onSelected: (index) {
                    setState(() {
                      debugPrint("Selected Emotion: ${_findEmotion(index)} and Index: $index");
                      _selectedEmotion = index;
                    });
                  },
                ),
              ),

              //Activities Section
              _activitiesBuilder(_findEmotion(_selectedEmotion)),

              //Exercise Section
              _exerciseBuilder(_findEmotion(_selectedEmotion)),

              // Extra space at the bottom for better scrolling
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activitiesBuilder(String emotion) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.local_activity_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Activities For You',
                style: AppTheme.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: AppTheme.spacingM,
            mainAxisSpacing: AppTheme.spacingM,
            childAspectRatio: 1.3,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ActivityCard(title: 'Games', icon: Icons.games_rounded, onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GamesPage()));
              }),
              ActivityCard(title: 'Goal Setting', icon: Icons.track_changes_rounded, onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GoalSettingPage()));
              }),
             ActivityCard(
  title: 'Breathing',
  icon: Icons.air_rounded,
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Breathing Exercise"),
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: BreathingExerciseWidget(
                colorScheme: ColorScheme(
                  primary: AppTheme.primaryMedium,
                  secondary: AppTheme.accent,
                  surface: Colors.white,
                  error: AppTheme.error,
                  onPrimary: Colors.white,
                  onSecondary: Colors.white,
                  onSurface: Colors.black,
                  onError: Colors.white,
                  brightness: Brightness.light,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  },
),

              ActivityCard(title: 'Journaling', icon: Icons.book_rounded, onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        Scaffold(
                            appBar: AppBar(
                              title: const Text("Gratitude Journal"),
                              backgroundColor: AppTheme.primaryDark,
                              foregroundColor: Colors.white,
                            ),
                            body: Container(
                                padding: const EdgeInsets.all(AppTheme.spacingM),
                                margin: const EdgeInsets.all(AppTheme.spacingM),
                                child: GratitudeJournalWidget(
                                    colorScheme: ColorScheme(
                                        primary: AppTheme.primaryMedium,
                                        secondary: AppTheme.accent,
                                        surface: Colors.white,
                                        error: AppTheme.error,
                                        onPrimary: Colors.white,
                                        onSecondary: Colors.white,
                                        onSurface: Colors.black,
                                        onError: Colors.white,
                                        brightness: Brightness.light
                                    )
                                )
                            )
                        )
                ));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exerciseBuilder(String emotion) {
    final List<Exercise> exerciseList = exercise[emotion.toLowerCase()] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Exercises For You',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: exerciseList.length,
              itemBuilder: (context, index) {
                final Exercise ex = exerciseList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ExerciseDetailScreen(exercise: ex),
                    ));
                  },

                  // Exercise Card
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color.fromARGB(255, 0, 31, 84), Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              ex.image,
                              height: 110,
                              width: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            ex.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
