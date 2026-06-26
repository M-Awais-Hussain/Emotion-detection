import 'dart:typed_data';

Future<void> loadEmotionModel() async {
  throw UnsupportedError('Cannot load emotion model without dart:io or dart:js_interop');
}

Future<String> predictEmotion(Uint8List imageBytes) async {
  throw UnsupportedError('Cannot predict without dart:io or dart:js_interop');
}
