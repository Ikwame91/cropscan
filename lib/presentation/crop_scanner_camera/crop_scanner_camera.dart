// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cropscan_pro/core/services/tf_lite_model_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/detection_feedback_widget.dart';
import './widgets/loading_overlay_widget.dart';

class CropScannerCamera extends StatefulWidget {
  const CropScannerCamera({super.key});

  @override
  State<CropScannerCamera> createState() => CropScannerCameraState();
}

class CropScannerCameraState extends State<CropScannerCamera>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _isFrontCamera = false;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  bool _hasPermission = false;
  Offset? _focusPoint;

  // state value variables for Ml prediction results and status
  String _detectedCrop = '';
  double _confidence = 0.0;
  bool _isDetecting = false;
  bool _showDetectionFeedback = false;

  late AnimationController _focusAnimationController;
  late AnimationController _captureAnimationController;
  late Animation<double> _focusAnimation;
  late Animation<double> _captureAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _lockOrientation();
    // Removed _checkAndInitializeCamera() from here!
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

// This method will now be called externally when the tab is selected
  Future<void> initializeCameraOnDemand() async {
    if (_hasPermission &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      // Camera is already initialized and permissions are granted, no need to re-initialize
      return;
    }
    await _checkAndInitializeCamera();

    final tfliteModelServices = context.read<TfLiteModelServices>();
    if (tfliteModelServices.status == ModelPredictionStatus.initial ||
        tfliteModelServices.status == ModelPredictionStatus.error) {
      try {
        await tfliteModelServices.loadModelAndLabels();
      } catch (e) {
        debugPrint("Error loading ML model: $e");
        _showErrorDialog(
            "Failed to load crop detection model. Please restart the app.");
      }
    }
  }

  Future<void> _checkAndInitializeCamera() async {
    var cameraStatus = await Permission.camera.status;
    var photosStatus = await Permission.photos.status;

    bool granted = cameraStatus.isGranted && photosStatus.isGranted;

    if (granted) {
      setState(() {
        _hasPermission = true;
      });
      await _initilizeCameraComponents();
    } else if (cameraStatus.isPermanentlyDenied ||
        photosStatus.isPermanentlyDenied) {
      setState(() {
        _hasPermission = false;
      });
      _showPermissionDeniedDialog();
    } else {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.photos,
      ].request();

      cameraStatus = statuses[Permission.camera] ?? PermissionStatus.denied;
      photosStatus = statuses[Permission.photos] ?? PermissionStatus.denied;

      if (cameraStatus.isGranted && photosStatus.isGranted) {
        setState(() {
          _hasPermission = true;
        });
        await _initilizeCameraComponents();
      } else {
        setState(() {
          _hasPermission = false;
        });
        _showPermissionDeniedDialog();
      }
    }
  }

  Future<void> _initilizeCameraComponents() async {
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
      _showErrorDialog("No cameras found on this device");
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
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();

      setState(() {
        _currentZoomLevel = 1.0;
        _isFlashOn = false;
        _isProcessing = false;
      });
      _cameraController!.setFlashMode(FlashMode.off);
    } on CameraException catch (e) {
      debugPrint("Error initializing camera: $e ");
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
      _isFrontCamera = _cameras![_selectedCameraIndex].lensDirection ==
          CameraLensDirection.front;
    });
    HapticFeedback.lightImpact();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                // Instead of _closeCamera(), we simply pop the dialog.
                // The MainScreen will handle navigation, possibly to the Dashboard tab.
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
      double newZoomLevel = _currentZoomLevel * scale;
      newZoomLevel = newZoomLevel.clamp(_minZoomLevel, _maxZoomLevel);
      await _cameraController!.setZoomLevel(newZoomLevel);
      setState(() {
        _currentZoomLevel = newZoomLevel;
      });
    } on CameraException catch (e) {
      debugPrint("Error setting zoom level: $e");
    }
  }

  Future<void> _performDetection(XFile imageFile) async {
    final tfliteModelServices = context.read<TfLiteModelServices>();
    if (tfliteModelServices.status != ModelPredictionStatus.ready) {
      _showErrorDialog("Model is not ready. Please wait or restart the app");
      setState(() {
        _isDetecting = false;
      });
      return;
    }
    setState(() {
      _isDetecting = true;
      _showDetectionFeedback = false;
    });
    try {
      final File image = File(imageFile.path);
      final Map<String, dynamic>? result =
          await tfliteModelServices.predictedImage(image);
      if (result != null) {
        setState(() {
          _detectedCrop = result['label'];
          _confidence = result['confidence'];
          _showDetectionFeedback = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushNamed(
            context,
            "crop-detection-results",
            arguments: {
              'imagePath': imageFile.path,
              'detectedCrop': _detectedCrop,
              'confidence': _confidence,
            },
          );
        }
      } else {
        _showErrorDialog("Detection failed. Please try again.");
      }
    } catch (e) {
      debugPrint("Error during detection: $e");
      _showErrorDialog(
          "Failed to process image: ${e.toString().split(':').last.trim()}");
    } finally {
      setState(() {
        _isDetecting = false;
        _showDetectionFeedback = false;
      });
    }
  }

  void _captureImage() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isDetecting) {
      // Use _isDetecting to prevent multiple captures
      return;
    }

    _captureAnimationController.forward().then((_) {
      _captureAnimationController.reverse();
    });

    HapticFeedback.heavyImpact();

    XFile? imageFile;
    try {
      imageFile = await _cameraController!.takePicture();
      debugPrint("Image captured: ${imageFile.path}");

      // Trigger the ML prediction
      await _performDetection(imageFile);
    } on CameraException catch (e) {
      debugPrint("Error taking picture: $e");
      _showErrorDialog("Failed to capture image: ${e.description}");
      setState(() {
        _isDetecting = false; // Ensure reset if camera capture fails
      });
    }
  }

  void _openGallery() async {
    HapticFeedback.lightImpact();
    // Prevent opening gallery if detection is active
    if (_isDetecting) return;

    final ImagePicker imagePicker = ImagePicker();
    XFile? image;
    try {
      image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        debugPrint("Image selected: ${image.path}");

        // Trigger the ML prediction
        await _performDetection(image);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "Image selection cancelled",
        )));
      }
    } catch (e) {
      debugPrint("Error picking image from gallery: $e");
      _showErrorDialog("Failed to pick image from gallery.");
      setState(() {
        _isDetecting = false; // Ensure reset if gallery pick fails
      });
    }
  }

  // _closeCamera() is removed as it's not needed here; Navigator.pop is contextual.

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize camera only if it was disposed and we have permission
      if (_hasPermission) {
        _initilizeCameraComponents();
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _focusAnimationController.dispose();
    _captureAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
    if (!_hasPermission ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      // Display a placeholder or loading indicator if permissions aren't granted
      // or camera isn't initialized yet.
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_hasPermission) ...[
              CustomIconWidget(
                iconName: 'no_photography',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 64,
              ),
              SizedBox(height: 2.h),
              Text(
                'Camera access required',
                style: AppTheme.lightTheme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Please grant camera and photo library permissions to use this feature.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => _checkAndInitializeCamera(), // Allow retry
                child: const Text('Grant Permissions'),
              ),
            ] else ...[
              CircularProgressIndicator(),
              SizedBox(height: 2.h),
              Text('Initializing camera...',
                  style: AppTheme.lightTheme.textTheme.titleMedium),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            CameraPreviewWidget(
              isFrontCamera: _isFrontCamera,
              zoomLevel: _currentZoomLevel,
              onTapToFocus: _onTapToFocus,
              onPinchToZoom: _onPinchToZoom,
              controller: _cameraController,
            ),

            // Detection Frame Overlay
            _buildDetectionFrame(),

            // Focus Ring
            if (_focusPoint != null) _buildFocusRing(),

            // Top Overlay
            CameraOverlayWidget(
              isTop: true,
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
            if (_currentZoomLevel > 1.0) _buildZoomIndicator(),
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
                  onPressed: () {
                    _checkAndInitializeCamera();
                  },
                  child: Text('Grant Permission'),
                ),
              ),
              SizedBox(height: 2.h),
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
          '${_currentZoomLevel.toStringAsFixed(1)}x',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
