import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/productivity_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductivityService service = ProductivityService();
    int completedTasks = service.getTasks().where((t) => t.isCompleted).length;
    int completedGoals = service.getGoals().where((g) => g.isCompleted).length;
    int focusMinutes = service.getTotalFocusMinutes();

    final List<Map<String, dynamic>> achievements = [
      {
        'title': 'First Step',
        'desc': 'Complete your first task',
        'icon': Icons.star,
        'unlocked': completedTasks >= 1,
        'color': AppTheme.warning,
      },
      {
        'title': 'Task Master',
        'desc': 'Complete 50 tasks',
        'icon': Icons.task_alt,
        'unlocked': completedTasks >= 50,
        'color': AppTheme.primaryMedium,
      },
      {
        'title': 'Goal Getter',
        'desc': 'Achieve 10 goals',
        'icon': Icons.emoji_events,
        'unlocked': completedGoals >= 10,
        'color': AppTheme.success,
      },
      {
        'title': 'Deep Focus',
        'desc': 'Reach 100 focus hours',
        'icon': Icons.psychology,
        'unlocked': focusMinutes >= 100 * 60,
        'color': AppTheme.accent,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 0.85,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final ach = achievements[index];
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: ach['unlocked'] ? ach['color'] : AppTheme.borderLight,
                width: ach['unlocked'] ? 2 : 1,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  ach['icon'],
                  size: 48,
                  color: ach['unlocked'] ? ach['color'] : AppTheme.textLight,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  ach['title'],
                  style: AppTheme.headingSmall.copyWith(
                    color: ach['unlocked'] ? AppTheme.textPrimary : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
                  child: Text(
                    ach['desc'],
                    textAlign: TextAlign.center,
                    style: AppTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                if (ach['unlocked'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Text('Unlocked', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Text('Locked', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
