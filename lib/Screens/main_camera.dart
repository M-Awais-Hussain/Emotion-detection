import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import '../utils/platform_utils.dart';
import 'package:emotioneye/Screens/result_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/camera_service.dart';
import '../services/image_processor_service.dart';
import '../services/realtime_emotion_service.dart';
import '../widgets/photo_clicked_widget.dart';
import '../widgets/camera_help_dialog.dart';
import '../widgets/emotion_overlay_widget.dart';

class MainCamera extends StatefulWidget {
  const MainCamera({super.key, this.photoClicked = false, this.initialCameraIndex = 0});
  final bool photoClicked;
  final int initialCameraIndex;

  @override
  State<MainCamera> createState() => _MainCameraState();
}


class _MainCameraState extends State<MainCamera> with WidgetsBindingObserver {
  // bool textFieldVisibility = false;
  // final TextEditingController _controller  = TextEditingController();
  final CameraService _cameraService = CameraService();
  final RealtimeEmotionService _emotionService = RealtimeEmotionService();

  List<CameraDescription>? _cameras;
  late int _selectedCameraIndex;
  FlashMode _flashMode = FlashMode.auto;

  XFile? _capturedImage;
  bool _isProcessingImage = false;
  bool photoClicked = false;
  bool _isCameraInitialized = false;
  
  // Real-time emotion detection variables
  String _currentEmotion = 'detecting...';
  bool _isEmotionDetecting = false;
  bool _showEmotionOverlay = true;

  @override
  void initState() {
    super.initState();
    _selectedCameraIndex = widget.initialCameraIndex;
    WidgetsBinding.instance.addObserver(this);
    debugPrint("[MainCamera] initState() called. photoClicked: ${widget.photoClicked}");

    // Setup emotion detection callbacks
    _emotionService.onEmotionDetected = (emotion) {
      if (mounted) {
        setState(() {
          _currentEmotion = emotion;
        });
      }
    };

    _emotionService.onDetectionStatusChanged = (isDetecting) {
      if (mounted) {
        setState(() {
          _isEmotionDetecting = isDetecting;
        });
      }
    };

    if (!widget.photoClicked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("[MainCamera] Calling _initializeCamera() from post-frame");
        _initializeCamera();
      });
    } else {
      setState(() {
        photoClicked = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    debugPrint("----------------------in didChangeAppLifecycleState function");
    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Release camera when app is inactive or paused
      // _disposeCamera();
      // dispose();
      await Future.delayed(Duration(milliseconds: 500));
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize camera when app is resumed, but only if we're in camera mode
      if (!photoClicked && !_isCameraInitialized) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() async{
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _emotionService.dispose();
    debugPrint("----------------------In dispose function");
    _disposeCamera();

    //delay for preventing any race condition
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> _initializeCamera() async {
    debugPrint("[MainCamera] _initializeCamera() START. isCameraInitialized: $_isCameraInitialized");

    // disposing and reinitializing if already initialized
    if (_isCameraInitialized) {
      await _disposeCamera();
      return;
    }

    try {
      _cameras = await availableCameras();
      debugPrint("[MainCamera] availableCameras(): Found ${_cameras?.length}");

      if (_cameras != null && _cameras!.isNotEmpty) {
        await _cameraService.initializeCamera(_cameras!, _selectedCameraIndex);
        
        // Flash mode not available on web
        if (!kIsWeb) {
          await _cameraService.setFlashMode(_flashMode);
        }
        
        setState(() {
          _isCameraInitialized = true;
        });
        
        // Start real-time emotion detection (works on web too)
        _emotionService.startDetection(_cameraService.cameraController);
        
        debugPrint("[MainCamera] _isCameraInitialized set to true.");
      } else {
        _showSnackBar("No cameras available", isError: true);
      }
    } catch (e, s) {
      debugPrint("[MainCamera] ERROR during _initializeCamera(): $e\nStackTrace:\n$s\n-------");
      _showSnackBar("Camera initialization error: $e", isError: true);
    }

    debugPrint("[MainCamera] _initializeCamera() END. _isCameraInitialized: $_isCameraInitialized");
  }

  // Method to dispose camera resources
  Future<void> _disposeCamera() async {
    debugPrint("[MainCamera] _disposeCamera() called. isInitialized: $_isCameraInitialized");
    
    // Stop emotion detection before disposing camera
    _emotionService.stopDetection();
    
    if (_isCameraInitialized) {
      await _cameraService.dispose();
      setState(() {
        _isCameraInitialized = false;
      });
      debugPrint("[MainCamera] Camera disposed and _isCameraInitialized set to false.");
    }
  }

  Future<void> _capturePhoto() async {
    debugPrint("[MainCamera] _capturePhoto() called. isCameraInitialized? $_isCameraInitialized");

    if (!_isCameraInitialized) {
      _showSnackBar("Capture is not initialized", isError: true);
      debugPrint("[MainCamera] Camera is not initialized .");
      return;
    }

    setState(() {
      _isProcessingImage = true;
      // textFieldVisibility = true;
    });

    try {
      final image = await _cameraService.capturePhoto();
      final processed = (_selectedCameraIndex == 1)
          ? await flipImageHorizontally(image)
          : image;

      setState(() {
        _capturedImage = processed;
        photoClicked = true;
        // textFieldVisibility = true;
      });

      debugPrint("[MainCamera] Photo captured and stored at: ${processed.path}");
      await _disposeCamera();  // Safe to dispose here
    } catch (e) {
      debugPrint("[MainCamera] Photo capture ERROR: $e");
      _showSnackBar("Capture error: $e", isError: true);
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  Future<void> _pickFromGallery() async {
    debugPrint("----------------------PickFromGallery");
    
    if (_isProcessingImage) return;

    setState(() => _isProcessingImage = true);

    // Dispose camera if it's initialized
    await _disposeCamera();

    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          debugPrint("[pickFromGallery] Picked file is not null");
          _capturedImage = pickedFile;
          photoClicked = true;
          // textFieldVisibility = true;
        });
      } else {
        debugPrint("[pickFromGallery] Picked file is not null");
        debugPrint("[pickFromGallery] No image was selected.");
        // Optional: reset states if needed
        setState(() {
          photoClicked = false;
          _capturedImage = null;
          // textFieldVisibility = false;
        });
        _showSnackBar("No image selected.", isError: false);  // optional
      }

    } catch (e) {
      _showSnackBar("Gallery error: $e", isError: true);
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  Future<void> _flipCamera() async {
    debugPrint("----------------------flip Camera");
    if (_cameras == null || _cameras!.length <= 1) return;

    // First dispose the current camera
    await _disposeCamera();

    try {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      await _initializeCamera();
    } catch (e) {
      _showSnackBar("Camera switch error: $e", isError: true);
      // Try to recover by initializing the previous camera
      _selectedCameraIndex = (_selectedCameraIndex - 1 + _cameras!.length) % _cameras!.length;
      await _initializeCamera();
    }
  }

  Future<void> _toggleFlash() async {

    debugPrint("----------------------toggle flash");
    if (!_isCameraInitialized) return;

    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.auto:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.auto;
    }

    try {
      await _cameraService.setFlashMode(newMode);
      setState(() => _flashMode = newMode);
    } catch (e) {
      _showSnackBar("Flash error: $e", isError: true);
    }
  }

  IconData _getFlashIcon() {
    debugPrint("----------------------get flash icon");
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.torch:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  Future<void> _analyzeEmotion() async {
    debugPrint("----------------------analyzeEmotion");
    // if (_controller.text.isEmpty){
    //   _showSnackBar("Please enter Server IP Address!", isError: true);
    //   return;
    // }
    if (_capturedImage == null) return;

    try {
      debugPrint("--------------------- In try block of analyze emotion method");
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString("ip", _controller.text);

      // debugPrint("--------------------- IP in main_camera.dart: ${_controller.text}");

      if(!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            imageFile: XFile(_capturedImage!.path),
            cameraIndex: _selectedCameraIndex,
          ),
        ),
      ).then((_) {
        // This code runs when returning from the ResultPage
        setState(() {
          // Reset camera view state
          photoClicked = false;
          _capturedImage = null;
          // textFieldVisibility = false;
        });
      });
    } catch (e) {
      _showSnackBar("Error: $e", isError: true);
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  void _togglePhotoClicked() async {

    debugPrint("----------------------togglePhotoClicked");
    setState(() {
      photoClicked = !photoClicked;
      _capturedImage = null;
      // textFieldVisibility = false;
    });

    // Initialize or dispose camera based on the new state
    if (!photoClicked) {
      _initializeCamera();
    } else {
      _disposeCamera();
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  void _toggleEmotionOverlay() {
    setState(() {
      _showEmotionOverlay = !_showEmotionOverlay;
    });
    debugPrint("[MainCamera] Emotion overlay toggled: $_showEmotionOverlay");
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          duration: Duration(seconds: 4),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red, // text/icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Text("Ok"),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildCameraPreview() {
    debugPrint("[MainCamera] _buildCameraPreview() called. Initialized: $_isCameraInitialized, PhotoClicked: $photoClicked");

    // Show loading indicator if camera isn't initialized yet
    if (!_isCameraInitialized && !photoClicked) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Initializing camera..."),
          ],
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Center(child: Text("Camera not available"));
    }

    final size = MediaQuery.of(context).size;
    final scale = 1 / (_cameraService.cameraController.value.aspectRatio * (size.width / size.height));

    return Transform.scale(
      scale: scale,
      child: CameraPreview(_cameraService.cameraController),
      // child: _selectedCameraIndex == 1
      //     ? Transform(
      //   alignment: Alignment.center,
      //   transform: Matrix4.rotationY(math.pi),
      //   child: CameraPreview(_cameraService.cameraController),
      // )
      //     : CameraPreview(_cameraService.cameraController),
    );
  }

  Widget _buildCapturedPreview() {
    debugPrint("----------------------buildCapturePreview");
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 10.0, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: buildImageFromXFile(_capturedImage, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // // Method to save ip to history
  // Future<void> _saveip(String ip) async {
  //   if (ip.isEmpty) return;
  //
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   // Save as current ip
  //   await prefs.setString('ip', ip);
  //
  //   // Save to ip history
  //   List<String> ipHistory = prefs.getStringList('ip_history') ?? [];
  //
  //   // Remove if already exists (to avoid duplicates)
  //   ipHistory.remove(ip);
  //
  //   // Add to front of list
  //   ipHistory.insert(0, ip);
  //
  //   // Limit history to 10 items
  //   if (ipHistory.length > 10) {
  //     ipHistory = ipHistory.sublist(0, 10);
  //   }
  //
  //   await prefs.setStringList('ip_history', ipHistory);
  // }
  //
  // // Method to show ip history dialog
  // void _showIpHistoryDialog(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> ipHistory = prefs.getStringList('ip_history') ?? [];
  //
  //   if (!context.mounted) return;
  //
  //   if (ipHistory.isEmpty) {
  //     _showSnackBar("No IP history available!", isError: true);
  //     return;
  //   }
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Select IP Address'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: ipHistory.length,
  //           itemBuilder: (context, index) {
  //             return ListTile(
  //               title: Text(ipHistory[index]),
  //               onTap: () {
  //                 setState(() {
  //                   // _controller.text = ipHistory[index];
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(225, 0, 31, 84),
        iconTheme: IconThemeData(
          color: Colors.white, // changes the back button color
        ),
        actions: [
          // Emotion overlay toggle
          if (_isCameraInitialized && !photoClicked)
            IconButton(
              icon: Icon(
                _showEmotionOverlay ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: _isProcessingImage ? null : _toggleEmotionOverlay,
              tooltip: _showEmotionOverlay ? 'Hide emotion detection' : 'Show emotion detection',
            ),
          if (_isCameraInitialized && _selectedCameraIndex == 0)
            IconButton(
              icon: Icon(_getFlashIcon(), color: Colors.white),
              onPressed: _isProcessingImage ? null : _toggleFlash,
            ),
          IconButton(
            icon: const Icon(Icons.help_outline_sharp, color: Colors.white),
            onPressed: _isProcessingImage
                ? null
                : () => showDialog(
              context: context,
              builder: (context) => const CameraHelpDialog(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: photoClicked && _capturedImage != null
                    ? _buildCapturedPreview()
                    : _buildCameraPreview(),

              ),
              // Visibility(
              //   visible: textFieldVisibility && !_isProcessingImage,
              //   child: Padding(
              //     padding: const EdgeInsets.all(10.0),
              //     child: TextField(
              //       controller: _controller,
              //       autofocus: false,
              //       decoration: InputDecoration(
              //         hintText: 'e.g: 192.168.1.1',
              //         labelText: 'Enter Server IP Address',
              //         border: OutlineInputBorder(),
              //         suffixIcon: Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             IconButton(
              //               icon: Icon(Icons.history),
              //               tooltip: 'Show IP history',
              //               onPressed: () {
              //                 _showIpHistoryDialog(context);
              //               },
              //             ),
              //             IconButton(
              //               icon: Icon(Icons.save),
              //               tooltip: 'Save IP',
              //               onPressed: () async {
              //                 final ip = _controller.text.trim();
              //                 if(ip.isEmpty){
              //                   _showSnackBar("IP Field is empty!", isError: true);
              //                 }else {
              //                   await _saveip(ip);
              //                   _showSnackBar("IP Saved");
              //                 }
              //               },
              //             ),
              //           ],
              //         ),
              //       ),
              //       keyboardType: TextInputType.numberWithOptions(decimal: true),
              //       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9\.]*$'))],
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 80,
                child: PhotoClickedWidget(
                  photoClicked: photoClicked,
                  togglePhotoClicked: _togglePhotoClicked,
                  capturePhoto: _capturePhoto,
                  pickFromGallery: _pickFromGallery,
                  flipCamera: _flipCamera,
                  onCheckPressed: _analyzeEmotion,
                  onCheckLoading: _isProcessingImage,
                  isProcessing: _isProcessingImage,
                ),
              ),
            ],
          ),
          // Emotion overlay for real-time detection
          if (_isCameraInitialized && !photoClicked)
            EmotionOverlayWidget(
              emotion: _currentEmotion,
              isDetecting: _isEmotionDetecting,
              showOverlay: _showEmotionOverlay,
            ),
        ],
      ),
    );
  }
}