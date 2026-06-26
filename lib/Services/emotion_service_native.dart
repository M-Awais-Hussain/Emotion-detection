import 'dart:io';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'emotion_service_shared.dart';

late OrtSession _session;
final FaceDetector _faceDetector = FaceDetector(
  options: FaceDetectorOptions(
    enableContours: false,
    enableLandmarks: false,
    enableClassification: false,
    enableTracking: false,
    performanceMode: FaceDetectorMode.fast,
  ),
);

Future<void> loadEmotionModel() async {
  OrtEnv.instance.init();
  final sessionOptions = OrtSessionOptions();
  final rawAssetFile = await rootBundle.load('assets/emotion_model.onnx');
  final bytes = rawAssetFile.buffer.asUint8List();
  _session = OrtSession.fromBuffer(bytes, sessionOptions);
}

Future<Uint8List> detectAndCropFace(Uint8List imageBytes) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/temp_face_detect.jpg');
  await tempFile.writeAsBytes(imageBytes);

  final inputImage = InputImage.fromFilePath(tempFile.path);
  final faces = await _faceDetector.processImage(inputImage);

  // Clean up
  if (await tempFile.exists()) {
    await tempFile.delete();
  }

  if (faces.isEmpty) {
    throw Exception("No face detected");
  }

  final face = faces.first;
  final boundingBox = face.boundingBox;

  final croppedBytes = await cropImageBytes(
    imageBytes,
    boundingBox.left.toInt(),
    boundingBox.top.toInt(),
    boundingBox.width.toInt(),
    boundingBox.height.toInt(),
  );

  return croppedBytes ?? imageBytes;
}

Future<String> predictEmotion(Uint8List imageBytes) async {
  Uint8List faceBytes;
  try {
    faceBytes = await detectAndCropFace(imageBytes);
  } catch (e) {
    return "none";
  }

  final inputData = await preprocessImageBytes(faceBytes);
  final listData = inputData.toList();
  
  final tensor = OrtValueTensor.createTensorWithDataList(
    listData,
    [1, 3, 224, 224],
  );
  
  final inputs = {'input': tensor};
  
  final runOptions = OrtRunOptions();
  final outputs = await _session.runAsync(runOptions, inputs);
  
  runOptions.release();
  
  if (outputs == null || outputs.isEmpty || outputs[0] == null) {
    tensor.release();
    return "Error: Inference failed";
  }
  
  final result = outputs[0]!.value as List;
  final scores = List<double>.from(result[0]);

  int bestIndex = 0;
  double bestScore = scores[0];

  for (int i = 1; i < scores.length; i++) {
    if (scores[i] > bestScore) {
      bestScore = scores[i];
      bestIndex = i;
    }
  }
  
  tensor.release();
  return emotionLabels[bestIndex];
}
