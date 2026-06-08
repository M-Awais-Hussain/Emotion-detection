
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

// Conditional imports
import 'file_utils_io.dart' if (dart.library.html) 'file_utils_stub.dart' as file_utils;

/// Check if running on web
bool get isWeb => kIsWeb;

/// Get image bytes from XFile (works on web and mobile)
Future<Uint8List> getImageBytes(XFile file) async {
  // XFile.readAsBytes() works on both web and mobile
  return await file.readAsBytes();
}

/// Display image from XFile (works on web and mobile)
Widget buildImageFromXFile(XFile? imageFile, {BoxFit fit = BoxFit.cover}) {
  if (imageFile == null) {
    return const SizedBox.shrink();
  }

  if (kIsWeb) {
    // On web, use Image.memory with bytes
    return FutureBuilder<Uint8List>(
      future: imageFile.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Icon(Icons.error);
        }
        return Image.memory(
          snapshot.data!,
          fit: fit,
        );
      },
    );
  } else {
    // On mobile, use Image.file
    final file = file_utils.createFile(imageFile.path);
    return Image.file(
      file,
      fit: fit,
    );
  }
}

/// Display image from file path (works on web and mobile)
Widget buildImageFromPath(String? imagePath, {BoxFit fit = BoxFit.cover}) {
  if (imagePath == null || imagePath.isEmpty) {
    return const SizedBox.shrink();
  }

  if (kIsWeb) {
    // On web, path might be a data URL or we need to load it differently
    // For now, return placeholder - you may need to handle web paths differently
    return const Icon(Icons.image);
  } else {
    // On mobile, use Image.file
    final file = file_utils.createFile(imagePath);
    return Image.file(
      file,
      fit: fit,
    );
  }
}

/// Check if file exists (web-safe)
Future<bool> fileExists(String path) async {
  if (kIsWeb) {
    // On web, we can't check file existence the same way
    // Assume it exists if we have a path
    return path.isNotEmpty;
  } else {
    final file = file_utils.createFile(path);
    return await file.exists();
  }
}
