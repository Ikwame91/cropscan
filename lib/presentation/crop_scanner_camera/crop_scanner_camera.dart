import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/detection_feedback_widget.dart';
import './widgets/loading_overlay_widget.dart';

class CropScannerCamera extends StatefulWidget {
  const CropScannerCamera({super.key});

  @override
  State<CropScannerCamera> createState() => _CropScannerCameraState();
}

class _CropScannerCameraState extends State<CropScannerCamera>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _isFrontCamera = false;
  double _currentzoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  bool _hasPermission = false;
  bool _showDetectionFeedback = false;
  String _detectedCrop = '';
  double _confidence = 0.0;
  Offset? _focusPoint;

  late AnimationController _focusAnimationController;
  late AnimationController _captureAnimationController;
  late Animation<double> _focusAnimation;
  late Animation<double> _captureAnimation;

  // Mock detection data
  final List<Map<String, dynamic>> _mockDetections = [
    {
      'crop': 'Bell Pepper',
      'confidence': 0.92,
      'position': Offset(0.4, 0.3),
    },
    {
      'crop': 'Tomato',
      'confidence': 0.87,
      'position': Offset(0.6, 0.5),
    },
    {
      'crop': 'Maize',
      'confidence': 0.94,
      'position': Offset(0.3, 0.7),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
    _initializeAnimations();
    _lockOrientation();
    _initilizeCamera();
  }

  void _initializeAnimations() {
    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _focusAnimationController,
      curve: Curves.easeInOut,
    ));

    _captureAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _captureAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _lockOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initilizeCamera() async {
    //requesting camera and gallery permissions
    final cameraStatus = await Permission.camera.request();
    final galleryStatus = await Permission.photos.request();

    if (cameraStatus.isGranted && galleryStatus.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _selectedCameraIndex = _cameras!.indexWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back);
        if (_selectedCameraIndex == -1) {
          _selectedCameraIndex = 0;
        }
        await _setupCameraController(_selectedCameraIndex);
      } else {
        setState(() {
          _hasPermission = false;
        });
      }
    } else {
      setState(() {
        _hasPermission = false;
      });
      _showPermissionDeniedDialog();
    }
  }

  Future _setupCameraController(int cameraIndex) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    _cameraController = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      _minZoomLevel = await _cameraController!.getMaxZoomLevel();
      _maxZoomLevel = await _cameraController!.getMinZoomLevel();

      setState(() {
        _currentzoomLevel = 1.0;
        _isFlashOn = false;
        _isProcessing = false;
      });
      _cameraController!.setFlashMode(FlashMode.off);
    } on CameraException catch (e) {
      debugPrint("Error initializing camera:  $e ");
      setState(() {
        _hasPermission = false;
      });
      _showErrorDialog("Failed to initialize camera. Please try again.");
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      HapticFeedback.lightImpact();
    } on CameraException catch (e) {
      debugPrint("error toggling flash: $e");
      _showErrorDialog("Failed to toggle flash.");
    }
  }

  void _flipCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return;
    }
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _setupCameraController(_selectedCameraIndex);
    setState(() {
      // _isFrontCamera = !_isFrontCamera;
      // _currentzoomLevel = 1.0;
      // _minZoomLevel = 1.0;
      // _maxZoomLevel = 1.0;
    });
    HapticFeedback.lightImpact();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permission Denied"),
          content: const Text(
              "Camera and Photo Library permissions are required to use this feature. Please enable them in your app settings."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
                _closeCamera();
              },
            ),
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onTapToFocus(Offset position) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final double normalizedX =
          position.dx / MediaQuery.of(context).size.width;
      final double normalizedY =
          position.dy / MediaQuery.of(context).size.height;

      final Offset adjustedPoint = Offset(normalizedX, normalizedY);

      //set focus and exposure points
      await _cameraController!.setFocusPoint(adjustedPoint);
      await _cameraController!.setExposurePoint(adjustedPoint);

      setState(() {
        _focusPoint = position;
      });

      _focusAnimationController.forward(from: 0.0).then((_) {
        _focusAnimationController.reverse();
        _focusPoint = null;
      });
      HapticFeedback.selectionClick();
    } on CameraException catch (e) {
      debugPrint("Error setting focus/exposure point: $e");
    }
  }

  void _onPinchToZoom(double scale) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      double newZoomLevel = _currentzoomLevel * scale;
      newZoomLevel = newZoomLevel.clamp(_minZoomLevel, _maxZoomLevel);
      await _cameraController!.setZoomLevel(newZoomLevel);
      setState(() {
        _currentzoomLevel = newZoomLevel;
      });
    } on CameraException catch (e) {
      debugPrint("Error setting zoom level: $e");
    }
  }

  void _captureImage() async {}

  void _openGallery() async {
    HapticFeedback.lightImpact();
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _showDetectionFeedback = false;
    });
    final ImagePicker imagePicker = ImagePicker();
    XFile? image;
    try {
      image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        debugPrint("Image selected: ${image.path}");
        await Future.delayed(const Duration(seconds: 2));

        //random detection result
        final detection = _mockDetections[
            DateTime.now().millisecondsSinceEpoch % _mockDetections.length];
        setState(() {
          _detectedCrop = detection['crop'];
          _confidence = detection['confidence'];

          _showDetectionFeedback = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isProcessing = false;
          _showDetectionFeedback = false;
        });
      }
    } catch (e) {}
  }

  void _closeCamera() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _focusAnimationController.dispose();
    _captureAnimationController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return _buildPermissionScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            CameraPreviewWidget(
              isFrontCamera: _isFrontCamera,
              zoomLevel: _zoomLevel,
              onTapToFocus: _onTapToFocus,
              onPinchToZoom: _onPinchToZoom,
            ),

            // Detection Frame Overlay
            _buildDetectionFrame(),

            // Focus Ring
            if (_focusPoint != null) _buildFocusRing(),

            // Top Overlay
            CameraOverlayWidget(
              isTop: true,
              onClose: _closeCamera,
              onFlashToggle: _toggleFlash,
              isFlashOn: _isFlashOn,
            ),

            // Bottom Overlay
            CameraOverlayWidget(
              isTop: false,
              onCapture: _captureImage,
              onGallery: _openGallery,
              onFlipCamera: _flipCamera,
              captureAnimation: _captureAnimation,
            ),

            // Detection Feedback
            if (_showDetectionFeedback)
              DetectionFeedbackWidget(
                cropName: _detectedCrop,
                confidence: _confidence,
              ),

            // Loading Overlay
            if (_isProcessing) LoadingOverlayWidget(),

            // Zoom Indicator
            if (_zoomLevel > 1.0) _buildZoomIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionScreen() {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'camera_alt',
                size: 20.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 4.h),
              Text(
                'Camera Permission Required',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'CropScan Pro needs camera access to identify crops. Please grant camera permission to continue.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkCameraPermission,
                  child: Text('Grant Permission'),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: _closeCamera,
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionFrame() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
            width: 2.0,
          ),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 25.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusRing() {
    return Positioned(
      left: _focusPoint!.dx - 30,
      top: _focusPoint!.dy - 30,
      child: AnimatedBuilder(
        animation: _focusAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _focusAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Positioned(
      top: 15.h,
      right: 4.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_zoomLevel.toStringAsFixed(1)}x',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
