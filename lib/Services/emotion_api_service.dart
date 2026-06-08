import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class EmotionApiService {
  // Mapping function to convert 7 model emotions to 5 app emotions
  static String _mapModelEmotionToAppEmotion(String modelEmotion) {
    final lower = modelEmotion.toLowerCase();
    switch (lower) {
      case 'angry':
      case 'happy':
      case 'sad':
      case 'neutral':
      case 'fear':
      case 'disgust':
      case 'surprise':
        return lower;
      case 'disgusted':
        return 'disgust';
      case 'anxious':
        return 'fear';
      default:
        return 'neutral'; // Default fallback
    }
  }

  static Future<String> getEmotion(XFile image) async {
    final ip = ApiConfig.predictEmotionUrl;

    // Fallback to old API if new backend not available
    final fallbackUrl = "https://darshanvaru-emotion-eye-detector.hf.space/predict";

    debugPrint("_______________API Link in emotion_api_service.dart: $ip");
    
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ip),
      );
      
      // Handle web and mobile differently
      if (kIsWeb) {
        // On web, use bytes directly
        final imageBytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
        ));
      } else {
        // On mobile, use file path
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send().timeout(const Duration(seconds: 3));
      final resBody = await response.stream.bytesToString();
      debugPrint("_______________ Status: ${response.statusCode}");
      debugPrint("_______________ Response: $resBody");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(resBody);
        
        // New backend returns mapped emotion directly
        final emotion = decoded['emotion'] ?? 'unknown';
        debugPrint("_______________ Detected Emotion: $emotion");
        
        // If emotion is 'none', return it directly
        if (emotion == 'none') {
          return 'none';
        }
        
        // Backend already maps emotions, but keep mapping function for compatibility
        final appEmotion = _mapModelEmotionToAppEmotion(emotion);
        debugPrint("_______________ Final App Emotion: $appEmotion");

        return appEmotion;
      } else {
        throw Exception('API Error ${response.statusCode}: $resBody');
      }
    } catch (e) {
      debugPrint("_______________ Error in emotion detection: $e");
      debugPrint("_______________ Trying fallback API...");
      
      // Fallback to old API if new backend fails
      try {
        final fallbackRequest = http.MultipartRequest('POST', Uri.parse(fallbackUrl));
        
        if (kIsWeb) {
          final imageBytes = await image.readAsBytes();
          fallbackRequest.files.add(http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'image.jpg',
          ));
        } else {
          fallbackRequest.files.add(await http.MultipartFile.fromPath('image', image.path));
        }
        
        final fallbackResponse = await fallbackRequest.send().timeout(const Duration(seconds: 5));
        final fallbackBody = await fallbackResponse.stream.bytesToString();
        
        if (fallbackResponse.statusCode == 200) {
          final decoded = jsonDecode(fallbackBody);
          final modelEmotion = decoded['emotion'] ?? 'unknown';
          debugPrint("_______________ Fallback API emotion: $modelEmotion");
          return _mapModelEmotionToAppEmotion(modelEmotion);
        } else {
          throw Exception('Fallback API also failed: ${fallbackResponse.statusCode}');
        }
      } catch (fallbackError) {
        debugPrint("_______________ Fallback API also failed: $fallbackError");
        rethrow;
      }
    }
  }
}
