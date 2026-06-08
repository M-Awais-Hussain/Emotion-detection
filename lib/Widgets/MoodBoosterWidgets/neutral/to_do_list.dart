import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToDoList extends StatefulWidget {
  // Neutral Color scheme
  final ColorScheme colorScheme = const ColorScheme(
    primary: Color(0xFF78909C),
    secondary: Color(0xFFB0BEC5),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  late SharedPreferences prefs;
  List<Map<String, dynamic>> tasks = [];
  final TextEditingController _addTaskController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint("------[init] isTaskEmpty: ${tasks.isEmpty} Tasks: $tasks");
    _initializeData();
  }

  @override
  void dispose() {
    _addTaskController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    debugPrint("------[initializeData] Tasks: $tasks");
    prefs = await SharedPreferences.getInstance();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasksJson = prefs.getStringList('tasks') ?? [];
    if (mounted) {
      setState(() {
        tasks = tasksJson.map((task) => Map<String, dynamic>.from(json.decode(task))).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final tasksJson = tasks.map((task) => json.encode(task)).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  void _toggleTaskComplete(int index) {
    setState(() {
      tasks[index]['isComplete'] = !(tasks[index]['isComplete'] ?? false);
      _saveTasks();
    });
  }

  void _addTask(String newTask) {
    setState(() {
      tasks.insert(0, {
        'title': newTask,
        'isComplete': false,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      _saveTasks();
    });
    _addTaskController.clear();
    // Scroll to top when new task is added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "To Do List",
                style: TextStyle(
                  color: widget.colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          // Input Field
          TextFormField(
            controller: _addTaskController,
            decoration: InputDecoration(
              hintText: 'Add a new task...',
              hintStyle: TextStyle(color: widget.colorScheme.onSurface.withValues(alpha: 0.5)),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: widget.colorScheme.primary),
                onPressed: () {
                  if (_addTaskController.text.trim().isNotEmpty) {
                    _addTask(_addTaskController.text.trim());
                  }
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colorScheme.primary),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: widget.colorScheme.secondary, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _addTask(value.trim());
              }
            },
          ),

          // Task List
          Expanded(
            child: tasks.isEmpty
                ? Text(
                  '\n\n\nNo tasks yet!\nAdd some tasks to get started.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _buildTaskItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(int index) {
    final task = tasks[index];
    final isComplete = task['isComplete'] ?? false;

    return Dismissible(
      key: Key(task['id']),
      background: Container(color: widget.colorScheme.secondary.withValues(alpha: 0.2)),
      onDismissed: (_) => _deleteTask(index),
      child: Card(
        color: Color(0xAAB0BEC5),//Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: widget.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        elevation: 1.5,
        child: ListTile(
          leading: Checkbox(
            value: isComplete,
            onChanged: (_) => _toggleTaskComplete(index),
            activeColor: widget.colorScheme.primary,
            checkColor: widget.colorScheme.onPrimary,
          ),
          title: Text(
            task['title'],
            style: TextStyle(
              color: isComplete
                  ? widget.colorScheme.onSurface.withValues(alpha: 0.4)
                  : widget.colorScheme.onSurface,
              decoration: isComplete ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: widget.colorScheme.error),
            onPressed: () => _deleteTask(index),
          ),
        ),
      ),
    );
  }
}