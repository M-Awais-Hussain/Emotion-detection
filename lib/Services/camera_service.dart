import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  CameraController get cameraController {
    debugPrint("[CameraService] Getting cameraController");
    return _cameraController!;
  }

  Future<void> get initializeFuture {
    debugPrint("[CameraService] Getting initializeFuture");
    return _initializeControllerFuture!;
  }

  Future<void> initializeCamera(List<CameraDescription> cameras, int selectedIndex) async {
    debugPrint("[CameraService] Initializing camera at index: $selectedIndex");

    _cameraController = CameraController(
      cameras[selectedIndex],
      ResolutionPreset.high,
    );

    try {
      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;
      debugPrint("[CameraService] Camera initialized successfully.");
    } catch (e) {
      debugPrint("[CameraService] Camera initialization FAILED: $e");
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    debugPrint("[CameraService] Setting flash mode to: $mode");
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        await _cameraController!.setFlashMode(mode);
        debugPrint("[CameraService] Flash mode set.");
      } catch (e) {
        debugPrint("[CameraService] Flash mode setting FAILED: $e");
      }
    } else {
      debugPrint("[CameraService] Flash mode cannot be set. Camera not initialized.");
    }
  }

  Future<XFile> capturePhoto() async {
    debugPrint("[CameraService] Capturing photo...");
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw Exception('[CameraService] Cannot take picture. Camera not initialized.');
    }

    try {
      final file = await _cameraController!.takePicture();
      debugPrint("[CameraService] Photo captured: ${file.path}");
      return file;
    } catch (e) {
      debugPrint("[CameraService] Photo capture FAILED: $e");
      rethrow;
    }
  }

    Future<void> dispose() async {
      debugPrint("[CameraService] Disposing cameraController...");
      if (_cameraController != null) {
        if (_cameraController!.value.isInitialized) {
          await _cameraController!.dispose();
          debugPrint("[CameraService] CameraController disposed.");
        }
        _cameraController = null;
      }
      _initializeControllerFuture = null;
    }
}
