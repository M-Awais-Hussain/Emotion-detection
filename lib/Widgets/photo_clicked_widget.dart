import 'package:flutter/material.dart';

class PhotoClickedWidget extends StatelessWidget {
  final bool photoClicked;
  final VoidCallback togglePhotoClicked;
  final VoidCallback capturePhoto;
  final VoidCallback pickFromGallery;
  final VoidCallback flipCamera;
  final VoidCallback onCheckPressed;
  final bool onCheckLoading;
  final bool isProcessing;

  const PhotoClickedWidget({
    super.key,
    required this.photoClicked,
    required this.togglePhotoClicked,
    required this.capturePhoto,
    required this.pickFromGallery,
    required this.flipCamera,
    required this.onCheckPressed,
    required this.onCheckLoading,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (photoClicked) {
      return Container(
        color: Color.fromRGBO(158, 158, 158, 100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: 'Retake',
              child: IconButton(
                onPressed: isProcessing ? null : togglePhotoClicked,
                icon: const Icon(Icons.replay, size: 40),
                color: isProcessing ? Colors.grey : Colors.black,
              ),
            ),
            const SizedBox(width: 190),
            onCheckLoading
                ? CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 3,
            )
                : Tooltip(
              message: 'Select',
              child: IconButton(
                onPressed: isProcessing ? null : onCheckPressed,
                icon: const Icon(Icons.check, size: 40),
                color: isProcessing ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      );
    }
    else {
      return Container(
        color: Color.fromRGBO(158, 158, 158, 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Tooltip(
                  message: 'Media',
                  child: IconButton(
                    onPressed: isProcessing ? null : pickFromGallery,
                    icon: const Icon(Icons.photo_library, size: 40, color: Colors.black),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 70,
                width: 70,
                child: FloatingActionButton(
                  onPressed: isProcessing ? null : capturePhoto,
                  shape: const CircleBorder(),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(225, 0, 31, 84),
                  child: isProcessing
                      ? const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Icon(Icons.camera_alt_rounded, size: 50),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 40.0),
                child: Tooltip(
                  message: 'Flip Camera',
                  child: IconButton(
                    onPressed: isProcessing ? null : flipCamera,
                    icon: const Icon(Icons.cameraswitch_rounded, size: 40, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
