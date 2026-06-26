import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/productivity_models.dart';
import '../services/productivity_service.dart';
import 'package:uuid/uuid.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final ProductivityService _service = ProductivityService();
  List<ProductivityHabit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    setState(() {
      _habits = _service.getHabits();
    });
  }

  void _showAddHabitDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
          title: const Text('Add New Habit'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Habit Name (e.g., Drink Water)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  final newHabit = ProductivityHabit(
                    id: const Uuid().v4(),
                    title: titleController.text.trim(),
                  );
                  await _service.addHabit(newHabit);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadHabits();
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryDark),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: _habits.isEmpty
          ? const Center(child: Text('No habits added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                bool isCompletedToday = habit.isCompletedToday;
                
                return Card(
                  elevation: 0,
                  color: AppTheme.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    side: BorderSide(color: AppTheme.borderLight),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                    title: Text(
                      habit.title,
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Streak: _calculateStreak(habit) days', style: AppTheme.bodySmall), // simplified for now
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            await _service.toggleHabitCompletion(habit);
                            _loadHabits();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingS),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompletedToday ? AppTheme.success : Colors.transparent,
                              border: Border.all(
                                color: isCompletedToday ? AppTheme.success : AppTheme.borderMedium,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              color: isCompletedToday ? Colors.white : AppTheme.borderMedium,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                          onPressed: () async {
                            await _service.deleteHabit(habit.id);
                            _loadHabits();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: AppTheme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
