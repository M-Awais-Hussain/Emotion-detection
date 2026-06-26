import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/productivity_models.dart';
import '../services/productivity_service.dart';
import 'package:uuid/uuid.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final ProductivityService _service = ProductivityService();
  List<ProductivityTask> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _service.getTasks();
    });
  }

  void _showAddTaskDialog([ProductivityTask? task]) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    String priority = task?.priority ?? 'Medium';
    DateTime? dueDate = task?.dueDate;

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
                  Text(task == null ? 'Add New Task' : 'Edit Task', style: AppTheme.headingMedium),
                  const SizedBox(height: AppTheme.spacingM),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      const Text('Priority: ', style: AppTheme.labelLarge),
                      const SizedBox(width: AppTheme.spacingS),
                      DropdownButton<String>(
                        value: priority,
                        items: ['High', 'Medium', 'Low'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setModalState(() {
                            priority = newValue!;
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

                        if (task == null) {
                          final newTask = ProductivityTask(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            priority: priority,
                            dueDate: dueDate,
                          );
                          await _service.addTask(newTask);
                        } else {
                          task.title = titleController.text.trim();
                          task.description = descController.text.trim();
                          task.priority = priority;
                          await _service.updateTask(task);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          _loadTasks();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      ),
                      child: Text(task == null ? 'Create Task' : 'Save Changes'),
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
        title: const Text('Tasks'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Add one to get started!'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  elevation: 0,
                  color: AppTheme.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    side: BorderSide(color: AppTheme.borderLight),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      activeColor: AppTheme.success,
                      onChanged: (val) async {
                        task.isCompleted = val ?? false;
                        await _service.updateTask(task);
                        _loadTasks();
                      },
                    ),
                    title: Text(
                      task.title,
                      style: AppTheme.bodyLarge.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty)
                          Text(task.description, style: AppTheme.bodySmall),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(task.priority).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.priority,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getPriorityColor(task.priority),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                      onPressed: () async {
                        await _service.deleteTask(task.id);
                        _loadTasks();
                      },
                    ),
                    onTap: () => _showAddTaskDialog(task),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        backgroundColor: AppTheme.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppTheme.error;
      case 'Medium':
        return AppTheme.warning;
      case 'Low':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }
}
