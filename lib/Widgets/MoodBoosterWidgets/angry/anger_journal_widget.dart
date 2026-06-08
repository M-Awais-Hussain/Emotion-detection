import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AngerJournalWidget extends StatefulWidget {
  final ColorScheme colorScheme = ColorScheme(
    primary: Color(0xFFE74C3C),
    secondary: Color(0xFF58D68D),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  AngerJournalWidget({super.key});

  @override
  AngerJournalWidgetState createState() => AngerJournalWidgetState();
}

class AngerJournalWidgetState extends State<AngerJournalWidget> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _entries = [];
  final String _storageKey = "anger_journal_entries";

  // Controllers
  final _triggerController = TextEditingController();
  final _emotionController = TextEditingController();
  final _physicalController = TextEditingController();
  final _thoughtsController = TextEditingController();
  final _responseController = TextEditingController();
  final _betterResponseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _triggerController.dispose();
    _emotionController.dispose();
    _physicalController.dispose();
    _thoughtsController.dispose();
    _responseController.dispose();
    _betterResponseController.dispose();
    super.dispose();
  }

  // Load saved entries from SharedPreferences
  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEntries = prefs.getString(_storageKey);
    if (savedEntries != null) {
      setState(() {
        _entries.addAll(List<Map<String, String>>.from(json.decode(savedEntries)));
      });
    }
  }

  // Save entries to SharedPreferences
  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(_entries));
  }

  void _submitEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _entries.add({
          'date': DateFormat('dd-MM-yyyy').format(DateTime.now()),
          'trigger': _triggerController.text,
          'emotion': _emotionController.text,
          'physical': _physicalController.text,
          'thoughts': _thoughtsController.text,
          'response': _responseController.text,
          'betterResponse': _betterResponseController.text,
        });
        _saveEntries();
      });

      // Clear form
      _triggerController.clear();
      _emotionController.clear();
      _physicalController.clear();
      _thoughtsController.clear();
      _responseController.clear();
      _betterResponseController.clear();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entry saved!'),
          backgroundColor: widget.colorScheme.primary,
        ),
      );
    }
  }

  // Show all entries in a dialog
  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anger Journal History'),
        content: SizedBox(
          width: double.maxFinite,
          child: _entries.isEmpty
              ? Center(child: Text("No Entries Found"))
              : ListView.builder(
            shrinkWrap: true,
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries.reversed.toList()[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: widget.colorScheme.surfaceContainerHighest,
                child: InkWell(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Confirm?"),
                        content: Text("Are you sure?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                          TextButton(
                            child: Text("OK", style: TextStyle(color: widget.colorScheme.primary)),
                            onPressed: () async {
                              Navigator.of(context).pop();
                                setState(() {
                                  _entries.removeAt(_entries.length - 1 - index);
                                  _saveEntries();
                                });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📅 ${entry['date']}', style: TextStyle(color: widget.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Text('🔥 Trigger: ${entry['trigger']}'),
                        Text('💢 Emotion: ${entry['emotion']}'),
                        Text('💪 Physical: ${entry['physical']}'),
                        Text('🤔 Thoughts: ${entry['thoughts']}'),
                        Text('🗣️ Response: ${entry['response']}'),
                        Text('✨ Better: ${entry['betterResponse']}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          // Heading: "Anger Tracker"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anger Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.colorScheme.primary,
                ),
              ),

              // History Button
              ElevatedButton.icon(
                onPressed: _showHistory,
                icon: const Icon(Icons.history),
                label: const Text('History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.colorScheme.primaryContainer,
                  foregroundColor: widget.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _triggerController,
                  label: 'Trigger (What happened?)',
                  hint: 'e.g., "My coworker interrupted me..."',
                ),
                _buildTextField(
                  controller: _emotionController,
                  label: 'Emotion (How did you feel?)',
                  hint: 'e.g., "Angry, disrespected"',
                ),
                _buildTextField(
                  controller: _physicalController,
                  label: 'Physical Reaction',
                  hint: 'e.g., "Clenched fists, fast heartbeat"',
                ),
                _buildTextField(
                  controller: _thoughtsController,
                  label: 'Thoughts',
                  hint: 'e.g., "They never listen to me!"',
                  maxLines: 3,
                ),
                _buildTextField(
                  controller: _responseController,
                  label: 'How You Responded',
                  hint: 'e.g., "I stayed quiet but felt resentful"',
                ),
                _buildTextField(
                  controller: _betterResponseController,
                  label: 'Better Response (Next Time)',
                  hint: 'e.g., "Politely ask to finish my point"',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorScheme.primary,
                    foregroundColor: widget.colorScheme.onPrimary,
                  ),
                  child: const Text('Save Entry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: widget.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please fill this field';
          }
          return null;
        },
      ),
    );
  }
}