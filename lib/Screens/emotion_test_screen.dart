import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/emotion_service.dart';

class EmotionTestScreen extends StatefulWidget {
  const EmotionTestScreen({super.key});

  @override
  State<EmotionTestScreen> createState() => _EmotionTestScreenState();
}

class _EmotionTestScreenState extends State<EmotionTestScreen> {
  XFile? selectedImage;
  String emotion = "";
  bool isLoading = false;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emotion Detection"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedImage != null)
              kIsWeb 
                ? Image.network(
                    selectedImage!.path,
                    height: 250,
                  )
                : Image.file(
                    File(selectedImage!.path),
                    height: 250,
                  )
            else
              const Icon(Icons.image, size: 100, color: Colors.grey),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  emotion = "";
                });
                
                selectedImage = await picker.pickImage(source: ImageSource.gallery);

                if (selectedImage != null) {
                  try {
                    final bytes = await selectedImage!.readAsBytes();
                    emotion = await predictEmotion(bytes);
                  } catch (e) {
                    emotion = "Error: \$e";
                  }
                }
                
                setState(() {
                  isLoading = false;
                });
              },
              child: const Text("Predict Emotion"),
            ),
            const SizedBox(height: 30),
            if (isLoading)
              const CircularProgressIndicator()
            else if (emotion.isNotEmpty)
              Text(
                emotion,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
