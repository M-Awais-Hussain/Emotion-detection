import 'package:camera/camera.dart';

class CameraControllerService {
  static Future<List<CameraDescription>> getAvailableCameras() => availableCameras();

  static Future<CameraController> initializeController(
      CameraDescription description,
      FlashMode flashMode,
      ) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller.initialize();
    await controller.setFlashMode(flashMode);
    return controller;
  }
}
