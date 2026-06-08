import 'package:flutter/material.dart';
import '../model/exercise_model.dart';
import '../theme/app_theme.dart';
import 'exercise_detail_screen.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  // Helper to capitalize emotion titles
  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exercise.entries.map((entry) {
                  return _buildEmotionSection(
                    context,
                    emotion: entry.key,
                    exercises: entry.value,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionSection(
      BuildContext context, {
        required String emotion,
        required List<Exercise> exercises,
      }) {
    Color emotionColor = AppTheme.getEmotionColor(emotion);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingXL),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emotion Header with enhanced design
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              gradient: AppTheme.getEmotionGradient(emotion),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: emotionColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: emotionColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    _getEmotionIcon(emotion),
                    color: emotionColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    _capitalize(emotion),
                    style: AppTheme.headingSmall.copyWith(
                      color: emotionColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: emotionColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                  ),
                  child: Text(
                    '${exercises.length} ${exercises.length == 1 ? 'Exercise' : 'Exercises'}',
                    style: AppTheme.labelMedium.copyWith(
                      color: emotionColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          // Exercises List
          ...exercises.map((ex) {
            return _buildExerciseCard(
              context,
              exercise: ex,
              emotionColor: emotionColor,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
      BuildContext context, {
        required Exercise exercise,
        required Color emotionColor,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExerciseDetailScreen(exercise: exercise),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.surfaceColor,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.borderLight,
                width: 1,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                // Exercise Image
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        emotionColor.withValues(alpha: 0.1),
                        emotionColor.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: Image.asset(
                      exercise.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                // Exercise Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        exercise.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: emotionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: emotionColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Assign icons per emotion
  IconData _getEmotionIcon(String emotion) {
    switch (emotion) {
      case "happy":
        return Icons.sentiment_satisfied_alt;
      case "sad":
        return Icons.sentiment_dissatisfied;
      case "angry":
        return Icons.mood_bad;
      case "neutral":
        return Icons.sentiment_neutral;
      case "fear":
        return Icons.sentiment_very_dissatisfied;
      case "disgust":
        return Icons.sick;
      case "surprise":
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
