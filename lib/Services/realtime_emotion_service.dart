import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'emotion_api_service.dart';

// Conditional imports
import '../utils/file_utils_io.dart' if (dart.library.html) '../utils/file_utils_stub.dart' as file_utils;

class RealtimeEmotionService {
  CameraController? _cameraController;
  bool _isDetecting = false;
  Function(String)? onEmotionDetected;
  Function(bool)? onDetectionStatusChanged;

  void startDetection(CameraController controller) {
    if (_isDetecting) return;
    
    _cameraController = controller;
    _isDetecting = true;
    onDetectionStatusChanged?.call(true);
    _detectEmotions();
  }

  void stopDetection() {
    _isDetecting = false;
    onDetectionStatusChanged?.call(false);
  }

  Future<void> _detectEmotions() async {
    while (_isDetecting && _cameraController != null) {
      try {
        if (!_cameraController!.value.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        // Capture image
        final image = await _cameraController!.takePicture();
        
        // Detect emotion
        final emotion = await EmotionApiService.getEmotion(image);
        
        // Notify listeners
        onEmotionDetected?.call(emotion);
        onDetectionStatusChanged?.call(_isDetecting);
        
        debugPrint("[RealtimeEmotionService] Detected emotion: $emotion");
        
        // Clean up the temporary image file (only on mobile)
        if (!kIsWeb) {
          try {
            final file = file_utils.createFile(image.path);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            debugPrint("[RealtimeEmotionService] Error deleting temp file: $e");
          }
        }
        
        // Wait before next detection
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        debugPrint("[RealtimeEmotionService] Error: $e");
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  void dispose() {
    stopDetection();
    _cameraController = null;
  }
}
