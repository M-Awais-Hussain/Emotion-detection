import 'dart:typed_data';
import 'package:image/image.dart' as img;

final List<String> emotionLabels = [
  "Ahegao",
  "Angry",
  "Happy",
  "Neutral",
  "Sad",
  "Surprise"
];

Future<Float32List> preprocessImageBytes(Uint8List bytes) async {
  img.Image image = img.decodeImage(bytes)!;
  
  image = img.copyResize(image, width: 224, height: 224);

  Float32List input = Float32List(1 * 3 * 224 * 224);
  int indexR = 0;
  int indexG = 224 * 224;
  int indexB = 2 * 224 * 224;

  for (int y = 0; y < 224; y++) {
    for (int x = 0; x < 224; x++) {
      final pixel = image.getPixel(x, y);
      double r = ((pixel.r / 255.0) - 0.5) / 0.5;
      double g = ((pixel.g / 255.0) - 0.5) / 0.5;
      double b = ((pixel.b / 255.0) - 0.5) / 0.5;

      input[indexR++] = r;
      input[indexG++] = g;
      input[indexB++] = b;
    }
  }
  return input;
}

Future<Uint8List?> cropImageBytes(Uint8List bytes, int x, int y, int width, int height) async {
  try {
    final image = img.decodeImage(bytes);
    if (image == null) return null;
    
    // Add padding (like the python backend did)
    int padding = 10;
    int cx = (x - padding).clamp(0, image.width);
    int cy = (y - padding).clamp(0, image.height);
    int cw = (width + padding * 2).clamp(0, image.width - cx);
    int ch = (height + padding * 2).clamp(0, image.height - cy);

    final croppedImage = img.copyCrop(image, x: cx, y: cy, width: cw, height: ch);
    return Uint8List.fromList(img.encodeJpg(croppedImage));
  } catch (e) {
    return null;
  }
}
