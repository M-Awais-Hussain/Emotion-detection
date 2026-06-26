import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/productivity_service.dart';
import 'package:intl/intl.dart';

import 'task_manager_screen.dart';
import 'goal_manager_screen.dart';
import 'focus_timer_screen.dart';
import 'habit_tracker_screen.dart';
import 'analytics_screen.dart';
import 'achievements_screen.dart';

class ProductivityDashboard extends StatefulWidget {
  const ProductivityDashboard({super.key});

  @override
  State<ProductivityDashboard> createState() => _ProductivityDashboardState();
}

class _ProductivityDashboardState extends State<ProductivityDashboard> {
  final ProductivityService _productivityService = ProductivityService();

  @override
  Widget build(BuildContext context) {
    double score = _productivityService.calculateDailyScore();
    String level = _productivityService.getScoreLevel(score);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity'),
        elevation: 0,
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppTheme.spacingL),
            _buildScoreCard(score, level),
            const SizedBox(height: AppTheme.spacingL),
            _buildMotivationalQuote(),
            const SizedBox(height: AppTheme.spacingL),
            Text('Quick Tools', style: AppTheme.headingSmall),
            const SizedBox(height: AppTheme.spacingM),
            _buildToolsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.primaryDark),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          today,
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildScoreCard(double score, String level) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Score',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                ),
              ),
              Text(
                '${score.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppTheme.accent, size: 32),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              "Small progress is still progress. Focus on one task at a time.",
              style: AppTheme.bodyMedium.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTheme.spacingM,
      mainAxisSpacing: AppTheme.spacingM,
      childAspectRatio: 1.1,
      children: [
        _buildToolCard(
          context,
          'Tasks',
          Icons.check_circle_outline,
          AppTheme.primaryLight,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskManagerScreen())).then((_) => setState(() {})),
        ),
        _buildToolCard(
          context,
          'Goals',
          Icons.track_changes,
          AppTheme.success,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalManagerScreen())).then((_) => setState(() {})),
        ),
        _buildToolCard(
          context,
          'Focus Timer',
          Icons.timer,
          AppTheme.warning,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusTimerScreen())).then((_) => setState(() {})),
        ),
        _buildToolCard(
          context,
          'Habits',
          Icons.repeat,
          AppTheme.accent,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitTrackerScreen())).then((_) => setState(() {})),
        ),
        _buildToolCard(
          context,
          'Analytics',
          Icons.bar_chart,
          AppTheme.primaryMedium,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())).then((_) => setState(() {})),
        ),
        _buildToolCard(
          context,
          'Achievements',
          Icons.emoji_events,
          AppTheme.sadColor,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())).then((_) => setState(() {})),
        ),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(title, style: AppTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
