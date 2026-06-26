import 'dart:js_interop';
import 'dart:typed_data';
import 'emotion_service_shared.dart';

@JS('initEmotionModel')
external JSPromise<JSBoolean> _initEmotionModelJS(JSString modelUrl);

@JS('predictEmotionModel')
external JSPromise<JSArray<JSNumber>> _predictEmotionModelJS(JSFloat32Array inputArray);

@JS('detectFaceBoundingBox')
external JSPromise<JSAny?> _detectFaceBoundingBoxJS(JSUint8Array imageBytes);

Future<void> loadEmotionModel() async {
  final result = await _initEmotionModelJS('assets/emotion_model.onnx'.toJS).toDart;
  if (!result.toDart) {
    throw Exception("Failed to load ONNX model on Web");
  }
}

Future<Uint8List> detectAndCropFace(Uint8List imageBytes) async {
  final jsBytes = imageBytes.toJS;
  final jsResult = await _detectFaceBoundingBoxJS(jsBytes).toDart;
  
  if (jsResult.isUndefinedOrNull) {
    throw Exception("No face detected");
  }
  
  final jsArray = jsResult as JSArray<JSNumber>;
  final dartArray = jsArray.toDart;
  
  final x = dartArray[0].toDartDouble.toInt();
  final y = dartArray[1].toDartDouble.toInt();
  final w = dartArray[2].toDartDouble.toInt();
  final h = dartArray[3].toDartDouble.toInt();
  
  final croppedBytes = await cropImageBytes(imageBytes, x, y, w, h);
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
  final jsInputArray = inputData.toJS;
  
  final resultsJS = await _predictEmotionModelJS(jsInputArray).toDart;
  final resultsDart = resultsJS.toDart;
  final scores = resultsDart.map((e) => e.toDartDouble).toList();

  int bestIndex = 0;
  double bestScore = scores[0];

  for (int i = 1; i < scores.length; i++) {
    if (scores[i] > bestScore) {
      bestScore = scores[i];
      bestIndex = i;
    }
  }
  
  return emotionLabels[bestIndex];
}
