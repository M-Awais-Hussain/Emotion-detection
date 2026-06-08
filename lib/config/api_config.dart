import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// API Configuration
/// Centralized configuration for backend API endpoints
class ApiConfig {
  // Backend base URL
  // For local development: 
  //   - Web/iOS Simulator: http://localhost:8000
  //   - Android Emulator: http://10.0.2.2:8000
  //   - Physical Device: http://YOUR_COMPUTER_IP:8000 (e.g., http://192.168.1.100:8000)
  // For production: https://your-backend-domain.com
  static String get baseUrl {
    final envUrl = const String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Auto-detect for Android
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          // For physical devices on same WiFi network, use computer's IP
          // For emulator, use 10.0.2.2
          // Default to local network IP for physical device
          // User can override with API_BASE_URL environment variable
          return 'http://10.0.2.2:8000';
        }
      } catch (e) {
        // Platform check might fail on some platforms, fall through to default
      }
    }
    
    // Default for web, iOS simulator, or other platforms
    return 'http://localhost:8000';
  }

  // API endpoints
  static const String predictEmotion = '/api/v1/predict';
  static const String chat = '/api/v1/chat';
  static const String contact = '/api/v1/contact';
  static const String health = '/health';

  // Full URLs
  static String get predictEmotionUrl => '$baseUrl$predictEmotion';
  static String get chatUrl => '$baseUrl$chat';
  static String get contactUrl => '$baseUrl$contact';
  static String get healthUrl => '$baseUrl$health';
}

