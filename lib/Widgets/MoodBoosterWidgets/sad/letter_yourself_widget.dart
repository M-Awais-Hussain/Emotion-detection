import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LetterYourself extends StatefulWidget {
  final ColorScheme colorScheme = ColorScheme(
    primary: Color(0xFF5DADE2),
    secondary: Color(0xFFF7DC6F),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  LetterYourself({super.key});

  @override
  State<LetterYourself> createState() => _LetterYourselfState();
}

class _LetterYourselfState extends State<LetterYourself> {
  final letterController = TextEditingController();
  List<String> savedLetters = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLetters();
  }

  Future<void> _loadSavedLetters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLetters = prefs.getStringList('letters') ?? [];
    });
  }

  Future<void> _saveLetter() async {
    String text = letterController.text.trim();
    if (text.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedLetters.insert(0, text); // add to beginning
    await prefs.setStringList('letters', savedLetters);

    letterController.clear();
    if(!mounted) return;
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Letter Sent"),
        content: Text("Your letter has been sent to your future."),
        actions: [
          TextButton(
            child: Text("OK", style: TextStyle(color: widget.colorScheme.primary)),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void _showSavedLetters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        if (savedLetters.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text("No saved letters yet.", style: TextStyle(fontSize: 16)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: savedLetters.length,
          itemBuilder: (_, index) {
            return GestureDetector(
              onLongPress: () async {
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
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          savedLetters.removeAt(index);
                          prefs.setStringList('letters', savedLetters);
                          setState(() {
                            _loadSavedLetters();
                          });
                          if(!mounted) return;
                          Navigator.pop(context);
                          _showSavedLetters();
                        },
                      )
                    ],
                  ),
                );
              },
              child: Card(
                color: widget.colorScheme.surface,
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    savedLetters[index],
                    style: TextStyle(
                      color: widget.colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Letter to yourself",
                  style: TextStyle(
                    color: widget.colorScheme.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showSavedLetters,
                icon: const Icon(Icons.history),
                label: const Text('History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.colorScheme.primaryContainer,
                  foregroundColor: widget.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: widget.colorScheme.primary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            padding: EdgeInsets.all(10),
            child: TextFormField(
              controller: letterController,
              maxLines: 10,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write here...',
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveLetter,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colorScheme.primary,
                foregroundColor: widget.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
              child: Text(
                "Send",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
