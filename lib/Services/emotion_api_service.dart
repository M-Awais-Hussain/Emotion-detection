import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'emotion_service.dart';

class EmotionApiService {
  // Mapping function to convert 7 model emotions to 5 app emotions
  static String _mapModelEmotionToAppEmotion(String modelEmotion) {
    final lower = modelEmotion.toLowerCase();
    switch (lower) {
      case 'ahegao':
      case 'angry':
      case 'happy':
      case 'sad':
      case 'neutral':
      case 'surprise':
        return lower;
      default:
        return 'neutral'; // Default fallback
    }
  }

  static Future<String> getEmotion(XFile image) async {
    debugPrint("_______________ Using Local ONNX Model for emotion detection");
    try {
      final imageBytes = await image.readAsBytes();
      final modelEmotion = await predictEmotion(imageBytes);
      
      debugPrint("_______________ Detected Emotion: $modelEmotion");
      
      if (modelEmotion == 'none') {
        return 'none';
      }
      
      final appEmotion = _mapModelEmotionToAppEmotion(modelEmotion);
      debugPrint("_______________ Final App Emotion: $appEmotion");

      return appEmotion;
    } catch (e) {
      debugPrint("_______________ Error in emotion detection: $e");
      throw Exception('Failed to predict emotion: $e');
    }
  }
}
