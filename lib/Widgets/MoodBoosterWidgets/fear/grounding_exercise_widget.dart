import 'package:flutter/material.dart';

/// 5-4-3-2-1 Grounding Technique widget for fear relief
/// Evidence-based cognitive behavioral technique to reduce fear and panic
class GroundingExerciseWidget extends StatefulWidget {
  final ColorScheme colorScheme = ColorScheme(
    primary: Color(0xFF48C9B0),
    secondary: Color(0xFFAF7AC5),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  GroundingExerciseWidget({super.key});

  @override
  GroundingExerciseWidgetState createState() => GroundingExerciseWidgetState();
}

class GroundingExerciseWidgetState extends State<GroundingExerciseWidget> {
  int _currentStep = 0;
  final List<String> _steps = [
    '5 things you can see',
    '4 things you can touch',
    '3 things you can hear',
    '2 things you can smell',
    '1 thing you can taste',
  ];

  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());
  bool _exerciseComplete = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5-4-3-2-1 Grounding Technique',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: widget.colorScheme.primary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'This exercise helps bring your focus to the present moment by engaging your senses.',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: widget.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 24),

        if (!_exerciseComplete) ...[
          // Current step indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${_currentStep + 1} of 5',
              style: TextStyle(
                color: widget.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Current step content
          Text(
            _steps[_currentStep],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),

          // Input field for current step
          TextField(
            controller: _controllers[_currentStep],
            decoration: InputDecoration(
              hintText: 'List items separated by commas',
              filled: true,
              fillColor: widget.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: widget.colorScheme.onSurface,
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (_currentStep > 0)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      color: widget.colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  if (_controllers[_currentStep].text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter at least one item'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  if (_currentStep < 4) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    setState(() {
                      _exerciseComplete = true;
                    });
                  }
                },
                child: Text(
                  _currentStep < 4 ? 'Next' : 'Complete',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Completion state
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.self_improvement,
                  color: widget.colorScheme.secondary,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  'Exercise Complete!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 16),

                // Summary of all steps
                ...List.generate(5, (index) {
                  if (_controllers[index].text.isEmpty) return SizedBox();

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _steps[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _controllers[index].text,
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 20),
                Text(
                  'Grounding techniques like this one help redirect your focus away '
                      'from fearful thoughts and back to the present moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: widget.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                      _exerciseComplete = false;
                      for (var controller in _controllers) {
                        controller.clear();
                      }
                    });
                  },
                  child: Text(
                    'Start Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}