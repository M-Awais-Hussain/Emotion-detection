// camera_help_dialog.dart
import 'package:flutter/material.dart';

class CameraHelpDialog extends StatelessWidget {
  const CameraHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text(
            'Please ensure you are in a well-lit environment for taking a photo. '
            'Make sure your face is clearly visible. '
            'If possible, then remove goggles if there is any.\n\n'
            'You can visit the Guide page from the home screen for more information.',
        textAlign: TextAlign.left,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
