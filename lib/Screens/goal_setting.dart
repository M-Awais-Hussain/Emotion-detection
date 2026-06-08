import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Goal {
  String title;
  String description;
  bool completed;

  Goal({required this.title, this.description = '', this.completed = false});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'completed': completed,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    title: json['title'],
    description: json['description'],
    completed: json['completed'],
  );
}

class GoalSettingPage extends StatefulWidget {
  const GoalSettingPage({super.key});

  @override
  GoalSettingPageState createState() => GoalSettingPageState();
}

class GoalSettingPageState extends State<GoalSettingPage> {
  final List<Goal> _goals = [];
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString('goals_data');
    if (goalsJson != null) {
      final List<dynamic> decoded = jsonDecode(goalsJson);
      setState(() {
        _goals.clear();
        _goals.addAll(decoded.map((json) => Goal.fromJson(json)));
      });
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_goals.map((e) => e.toJson()).toList());
    await prefs.setString('goals_data', encoded);
  }

  void _addGoal() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goal title cannot be empty')),
      );
      return;
    }

    setState(() {
      _goals.add(Goal(title: title, description: desc));
      _titleController.clear();
      _descController.clear();
    });
    _saveGoals();
  }

  void _toggleGoal(int index) {
    setState(() {
      _goals[index].completed = !_goals[index].completed;
    });
    _saveGoals();
  }

  void _deleteGoal(int index) {
    setState(() {
      _goals.removeAt(index);
    });
    _saveGoals();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color.fromARGB(255, 0, 31, 84);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Goal Setting'),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Goal Title",
                        prefixIcon: Icon(Icons.flag, color: primaryBlue),
                        labelStyle: TextStyle(color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryBlue.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: "Description (optional)",
                        prefixIcon: Icon(Icons.edit, color: primaryBlue),
                        labelStyle: TextStyle(color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryBlue.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryBlue, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _addGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      icon: Icon(Icons.add),
                      label: Text(
                        'Add Goal',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _goals.isEmpty
                    ? Center(child: Text('No goals set yet!'))
                    : ListView.builder(
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        onTap: () => _toggleGoal(index),
                        leading: Icon(
                          goal.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: goal.completed ? Colors.green : null,
                        ),
                        title: Text(
                          goal.title,
                          style: TextStyle(
                            decoration: goal.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: goal.description.isNotEmpty
                            ? Text(goal.description)
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteGoal(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
