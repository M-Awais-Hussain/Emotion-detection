import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class NativeCameraLauncher {
  static const platform = MethodChannel('com.example.emotioneye/camera');

  static Future<void> openNativeCamera() async {
    try {
      await platform.invokeMethod('openCameraApp');
    } on PlatformException catch (e) {
      debugPrint("Failed to open camera: '${e.message}'.");
    }
  }
}
