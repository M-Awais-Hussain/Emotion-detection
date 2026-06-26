import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/productivity_models.dart';
import '../services/productivity_service.dart';
import 'package:uuid/uuid.dart';

class GoalManagerScreen extends StatefulWidget {
  const GoalManagerScreen({super.key});

  @override
  State<GoalManagerScreen> createState() => _GoalManagerScreenState();
}

class _GoalManagerScreenState extends State<GoalManagerScreen> {
  final ProductivityService _service = ProductivityService();
  List<ProductivityGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() {
    setState(() {
      _goals = _service.getGoals();
    });
  }

  void _showAddGoalDialog([ProductivityGoal? goal]) {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final descController = TextEditingController(text: goal?.description ?? '');
    String type = goal?.type ?? 'Short-Term';
    double progress = goal?.progressPercentage ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: AppTheme.spacingM,
                right: AppTheme.spacingM,
                top: AppTheme.spacingL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal == null ? 'Add New Goal' : 'Edit Goal', style: AppTheme.headingMedium),
                  const SizedBox(height: AppTheme.spacingM),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      const Text('Type: ', style: AppTheme.labelLarge),
                      const SizedBox(width: AppTheme.spacingS),
                      DropdownButton<String>(
                        value: type,
                        items: ['Short-Term', 'Long-Term'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setModalState(() {
                            type = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  if (goal != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progress: ${(progress * 100).toInt()}%', style: AppTheme.labelLarge),
                        Slider(
                          value: progress,
                          activeColor: AppTheme.success,
                          onChanged: (val) {
                            setModalState(() {
                              progress = val;
                            });
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: AppTheme.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;

                        if (goal == null) {
                          final newGoal = ProductivityGoal(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            type: type,
                          );
                          await _service.addGoal(newGoal);
                        } else {
                          goal.title = titleController.text.trim();
                          goal.description = descController.text.trim();
                          goal.type = type;
                          goal.progressPercentage = progress;
                          goal.isCompleted = progress >= 1.0;
                          await _service.updateGoal(goal);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          _loadGoals();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      ),
                      child: Text(goal == null ? 'Create Goal' : 'Save Changes'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: _goals.isEmpty
          ? const Center(child: Text('No goals yet. Set your first goal!'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return Card(
                  elevation: 0,
                  color: AppTheme.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    side: BorderSide(color: AppTheme.borderLight),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppTheme.spacingM),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: goal.type == 'Short-Term' 
                                ? AppTheme.primaryLight.withValues(alpha: 0.1) 
                                : AppTheme.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            goal.type,
                            style: TextStyle(
                              fontSize: 10,
                              color: goal.type == 'Short-Term' ? AppTheme.primaryLight : AppTheme.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppTheme.spacingS),
                        if (goal.description.isNotEmpty)
                          Text(goal.description, style: AppTheme.bodySmall),
                        const SizedBox(height: AppTheme.spacingM),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: goal.progressPercentage,
                                backgroundColor: AppTheme.borderLight,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  goal.isCompleted ? AppTheme.success : AppTheme.primaryMedium,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text('${(goal.progressPercentage * 100).toInt()}%', style: AppTheme.labelMedium),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                      onPressed: () async {
                        await _service.deleteGoal(goal.id);
                        _loadGoals();
                      },
                    ),
                    onTap: () => _showAddGoalDialog(goal),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(),
        backgroundColor: AppTheme.success,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
