import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';

// Conditional imports
import '../utils/file_utils_io.dart' if (dart.library.html) '../utils/file_utils_stub.dart' as file_utils;

Future<XFile> flipImageHorizontally(XFile image) async {
  final bytes = await image.readAsBytes();
  final img = await decodeImageFromList(bytes);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final matrix = Matrix4.identity()
    ..translateByDouble(img.width.toDouble(), 0.0, 0.0, 1.0)
    ..scaleByDouble(-1.0, 1.0, 1.0, 1.0);
  canvas.transform(matrix.storage);
  canvas.drawImage(img, Offset.zero, Paint());

  final flippedImage = await recorder.endRecording().toImage(img.width, img.height);
  final pngBytes = await flippedImage.toByteData(format: ui.ImageByteFormat.png);

  if (kIsWeb) {
    // On web, create XFile from bytes directly
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'CAP$timestamp.png';
    return XFile.fromData(
      pngBytes!.buffer.asUint8List(),
      mimeType: 'image/png',
      name: filename,
    );
  } else {
    // On mobile, save to temp file
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'CAP$timestamp.png';
    final tempDir = await file_utils.getSystemTemp().createTemp();
    final tempFile = file_utils.createFile('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(pngBytes!.buffer.asUint8List());
    return XFile(tempFile.path);
  }
}
