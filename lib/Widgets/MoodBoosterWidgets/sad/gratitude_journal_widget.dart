import 'package:flutter/material.dart';

/// Gratitude journaling component based on positive psychology research
/// Proven to increase happiness and life satisfaction when practiced regularly
class GratitudeJournalWidget extends StatefulWidget {
  final ColorScheme colorScheme;

  const GratitudeJournalWidget({super.key, required this.colorScheme});

  @override
  GratitudeJournalWidgetState createState() => GratitudeJournalWidgetState();
}

class GratitudeJournalWidgetState extends State<GratitudeJournalWidget> {
  final List<TextEditingController> _controllers = List.generate(3,(_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(3,(_) => FocusNode(),);
  bool _completed = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gratitude Journal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.colorScheme.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Writing down things you\'re grateful for has been scientifically proven to:\n'
            '• Increase happiness\n• Improve sleep\n• Reduce stress\n• Strengthen relationships',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: widget.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 24),

          if (!_completed) ...[
            Text(
              'List three things you\'re grateful for today:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),

            // Gratitude input fields
            ...List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  decoration: InputDecoration(
                    hintText: 'Gratitude item ${index + 1}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.favorite,
                      color: widget.colorScheme.primary,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  textInputAction: index < 2
                      ? TextInputAction.next
                      : TextInputAction.done,
                )
              );
            }),

            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: _completeJournal,
              child: Text(
                'Complete Journal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.colorScheme.onPrimary,
                ),
              ),
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
                    Icons.check_circle,
                    color: widget.colorScheme.secondary,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Journal Complete!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.colorScheme.secondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Review what you\'re grateful for:',
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 16),

                  ...List.generate(3, (index) {
                    if (_controllers[index].text.isEmpty) return SizedBox();

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: widget.colorScheme.secondary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _controllers[index].text,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: widget.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 24),
                  Text(
                    'Research shows that reviewing your gratitude journal regularly '
                        'can amplify its positive effects on your mood and outlook.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: widget.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _completeJournal() {
    debugPrint("-----Complete Journal");
    // Validate at least one entry is filled
    final hasEntries = _controllers.any((c) => c.text.isNotEmpty);

    if (!hasEntries) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter at least one gratitude item'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _completed = true;
    });

    // Trigger haptic feedback
    Feedback.forTap(context);

    // Close keyboard
    FocusScope.of(context).unfocus();
  }
}