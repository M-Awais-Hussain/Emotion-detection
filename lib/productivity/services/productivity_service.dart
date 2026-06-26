import 'package:hive_flutter/hive_flutter.dart';
import '../models/productivity_models.dart';

class ProductivityService {
  static final ProductivityService _instance = ProductivityService._internal();

  factory ProductivityService() {
    return _instance;
  }

  ProductivityService._internal();

  // Box getters
  Box<ProductivityTask> get _tasksBox => Hive.box<ProductivityTask>('tasks');
  Box<ProductivityGoal> get _goalsBox => Hive.box<ProductivityGoal>('goals');
  Box<ProductivityHabit> get _habitsBox => Hive.box<ProductivityHabit>('habits');
  Box<PomodoroSession> get _pomodoroBox => Hive.box<PomodoroSession>('pomodoro_sessions');

  // --- Tasks ---
  List<ProductivityTask> getTasks() {
    return _tasksBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addTask(ProductivityTask task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> updateTask(ProductivityTask task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  // --- Goals ---
  List<ProductivityGoal> getGoals() {
    return _goalsBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addGoal(ProductivityGoal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  Future<void> updateGoal(ProductivityGoal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  // --- Habits ---
  List<ProductivityHabit> getHabits() {
    return _habitsBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addHabit(ProductivityHabit habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> toggleHabitCompletion(ProductivityHabit habit) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (habit.isCompletedToday) {
      // Remove today's completion
      habit.completedDates.removeWhere((d) => 
        d.year == today.year && d.month == today.month && d.day == today.day);
    } else {
      // Add today's completion
      habit.completedDates.add(today);
    }
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _habitsBox.delete(id);
  }

  // --- Pomodoro ---
  List<PomodoroSession> getPomodoroSessions() {
    return _pomodoroBox.values.toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<void> addPomodoroSession(PomodoroSession session) async {
    await _pomodoroBox.put(session.id, session);
  }

  // --- Analytics & Scoring ---
  
  double calculateDailyScore() {
    double score = 0;
    final now = DateTime.now();
    
    // Tasks: 5 points per completed task today (Max 30)
    int completedTasksToday = _tasksBox.values.where((t) => 
      t.isCompleted && t.createdAt.year == now.year && t.createdAt.month == now.month && t.createdAt.day == now.day
    ).length;
    score += (completedTasksToday * 5).clamp(0, 30);
    
    // Pomodoro: 10 points per completed session today (Max 40)
    int completedPomodorosToday = _pomodoroBox.values.where((p) => 
      p.isCompleted && p.startTime.year == now.year && p.startTime.month == now.month && p.startTime.day == now.day
    ).length;
    score += (completedPomodorosToday * 10).clamp(0, 40);
    
    // Habits: 5 points per habit completed today (Max 30)
    int completedHabitsToday = _habitsBox.values.where((h) => h.isCompletedToday).length;
    score += (completedHabitsToday * 5).clamp(0, 30);
    
    return score.clamp(0, 100);
  }

  String getScoreLevel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Average';
    return 'Needs Improvement';
  }

  // Analytics Helpers
  int getTotalFocusMinutes() {
    return _pomodoroBox.values
      .where((s) => s.isCompleted)
      .fold(0, (sum, s) => sum + s.durationMinutes);
  }
}
