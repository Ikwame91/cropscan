// ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cropscan_pro/core/services/tf_lite_model_services.dart';
import 'package:cropscan_pro/models/crop_detection_args.dart';
import 'package:cropscan_pro/models/crop_info.dart';
import 'package:cropscan_pro/presentation/crop_scanner_camera/widgets/enhancedloadingoverlay.dart';
import 'package:cropscan_pro/providers/naviagtion_provider.dart';
import 'package:flutter/foundation.dart';
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
  bool _isFrontCamera = false;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  bool _hasPermission = false;
  Offset? _focusPoint;
  bool _isPickingFromGallery = false;

  // state value variables for Ml prediction results and status
  String _detectedCrop = '';
  double _confidence = 0.0;
  bool _showDetectionFeedback = false;

  static const Duration _detectionFeedbackDuration = Duration(seconds: 3);
  static const Duration _focusAnimationDuration = Duration(milliseconds: 500);
  static const Duration _captureAnimationDuration = Duration(milliseconds: 300);
  static const double _detectionFrameHorizontalMargin =
      15.0; // Corresponds to 15.w
  static const double _detectionFrameVerticalMargin =
      25.0; // Corresponds to 25.h

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
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndInitializeCamera();
      });
    } else {
      _checkAndInitializeCamera();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (kDebugMode) {
      debugPrint("🔥 Hot reload detected");

      // Safer context access with error handling
      try {
        final navigationProvider = context.read<NavigationProvider>();
        if (navigationProvider.currentIndex == 1) {
          // Only reinitialize if camera is actually broken
          if (_cameraController == null ||
              !_cameraController!.value.isInitialized ||
              _cameraController!.value.hasError) {
            debugPrint("Camera needs reinitialization after hot reload");
            _handleHotReloadRecovery();
          } else {
            debugPrint("Camera appears healthy, skipping hot reload reinit");
          }
        } else {
          debugPrint("Camera tab not active - skipping reinit");
        }
      } catch (e) {
        debugPrint("Error accessing NavigationProvider during hot reload: $e");
        // Fallback: only reinitialize if camera is broken
        if (_cameraController == null ||
            !_cameraController!.value.isInitialized) {
          _handleHotReloadRecovery();
        }
      }
    }
  }

  Future<void> _handleHotReloadRecovery() async {
    try {
      if (_cameraController != null) {
        await _cameraController?.pausePreview();
        await Future.delayed(const Duration(milliseconds: 200));
        await _cameraController?.dispose();
        _cameraController = null;
      }

      // Longer delay for complete cleanup
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted && _hasPermission) {
        await _checkAndInitializeCamera();
      }
    } catch (e) {
      debugPrint("Hot reload recovery error: $e");
    }
  }

  void _initializeAnimations() {
    _focusAnimationController = AnimationController(
      duration: _focusAnimationDuration,
      vsync: this,
    );

    _captureAnimationController = AnimationController(
      duration: _captureAnimationDuration,
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

  void _setDetectionState({
    required bool showFeedback,
    String? detectedCrop,
    double? confidence,
  }) {
    if (mounted) {
      setState(() {
        _showDetectionFeedback = showFeedback;
        if (detectedCrop != null) _detectedCrop = detectedCrop;
        if (confidence != null) _confidence = confidence;
      });
    }
  }

  void _resetDetectionState() {
    if (mounted) {
      setState(() {
        _showDetectionFeedback = false;
        // CRITICAL FIX: Clear previous detection results completely
        _detectedCrop = '';
        _confidence = 0.0;
        _focusPoint = null;
        _isCapturing = false;
      });
    }
  }

  String _sanitizeError(dynamic error) {
    final errorStr = error.toString();
    final parts = errorStr.split(':');
    return parts.length > 1 ? parts.last.trim() : errorStr;
  }

  Future<void> _navigateToResults(
    String detectedCrop,
    double confidence,
    String imagePath,
  ) async {
    debugPrint("🚀 Navigating to results screen");
    debugPrint("Raw detection result: $detectedCrop");
    debugPrint("Confidence: $confidence");

    final CropInfo cropInfo = CropInfoMapper.getCropInfo(detectedCrop);

    debugPrint("Processed crop info: ${cropInfo.displayName}");

    // Type-safe navigation with proper arguments
    final navigationResult =
        await Navigator.pushNamed(context, AppRoutes.cropDetectionResults,
            arguments: CropDetectionResultsArgs(
                imagePath: imagePath,
                detectedCrop: detectedCrop, // Keep raw label for reference
                confidence: confidence,
                cropInfo: cropInfo,
                isFromHistory: false));

    debugPrint("✅ Returned from results screen");
    // Reset detection state after navigation
    _resetDetectionState();

    // Optional: Handle any return data from results screen
    if (navigationResult != null) {
      debugPrint("Results screen returned: $navigationResult");
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return; // Important check before showing SnackBar

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _checkAndInitializeCamera() async {
    debugPrint("Starting camera initialization...");
    var cameraStatus = await Permission.camera.status;
    var photosStatus = await Permission.photos.status;

    // --- Start of refined logic ---
    if (cameraStatus.isGranted && photosStatus.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      await _initilizeCameraComponents();
    } else if (cameraStatus.isPermanentlyDenied ||
        photosStatus.isPermanentlyDenied) {
      setState(() {
        _hasPermission = false;
      });
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
      }
    }
  }

// This method will now be called externally when the tab is selected
  Future<void> initializeCameraOnDemand() async {
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await _checkAndInitializeCamera();
    }

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

  Future<void> _initilizeCameraComponents() async {
    debugPrint("Initializing camera components...");

    // Reset any previous state
    _resetDetectionState();

    try {
      _cameras = await availableCameras();
      debugPrint("Available cameras: ${_cameras?.length ?? 0}");

      if (_cameras != null && _cameras!.isNotEmpty) {
        _selectedCameraIndex = _cameras!.indexWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back);
        if (_selectedCameraIndex == -1) {
          _selectedCameraIndex = 0;
        }
        debugPrint("Selected camera index: $_selectedCameraIndex");
        await _setupCameraController(_selectedCameraIndex);
      } else {
        debugPrint("No cameras found");
        if (mounted) {
          setState(() {
            _hasPermission = false;
          });
        }
        _showErrorDialog("No cameras found on this device");
      }
    } catch (e) {
      debugPrint("Error initializing camera components: $e");
      if (mounted) {
        setState(() {
          _hasPermission = false;
        });
      }
      _showErrorDialog("Failed to initialize camera: $e");
    }
  }

  Future<void> _retryPermissions() async {
    debugPrint("Retrying permissions...");
    setState(() {
      _hasPermission = false; // Reset state
    });
    await _checkAndInitializeCamera();
  }

  Future<void> _configureCameraSettings() async {
    if (_cameraController?.value.isInitialized == true) {
      try {
        await _cameraController!.setExposureMode(ExposureMode.auto);
        await _cameraController!.setFocusMode(FocusMode.auto);
        debugPrint("📸 Camera settings configured");
      } catch (e) {
        debugPrint("Warning: Could not configure camera settings: $e");
      }
    }
  }

  Future _setupCameraController(int cameraIndex) async {
    // CRITICAL FIX: Reset detection state and dispose previous controller completely
    _resetDetectionState();

    if (_cameraController != null) {
      try {
        await _cameraController!.pausePreview();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Increased delay
        await _cameraController!.dispose();
      } catch (e) {
        debugPrint("Error disposing previous camera: $e");
      } finally {
        _cameraController = null;
      }
    }

    // Longer delay to ensure complete cleanup
    await Future.delayed(const Duration(milliseconds: 200));

    _cameraController = CameraController(
      _cameras![cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) {
        await _cameraController!.dispose();
        return;
      }

      await _configureCameraSettings();

      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();

      setState(() {
        _currentZoomLevel = 1.0;
        _isFlashOn = false;
        _focusPoint = null; // Reset focus point
      });

      await _cameraController!.setFlashMode(FlashMode.off);

      // CRITICAL FIX: Ensure preview is properly started
      await Future.delayed(const Duration(milliseconds: 100));
      if (_cameraController?.value.isInitialized == true && mounted) {
        try {
          await _cameraController!.resumePreview();
          debugPrint("✅ Camera preview resumed after setup");
        } catch (e) {
          debugPrint("Warning: Could not resume preview: $e");
        }
      }
    } on CameraException catch (e) {
      debugPrint("Error initializing camera: $e ");

      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }
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

    // CRITICAL FIX: Reset detection state when switching cameras
    _resetDetectionState();

    await _cameraController?.pausePreview();

    if (_isFlashOn) {
      await _cameraController!.setFlashMode(FlashMode.off);
      setState(() {
        _isFlashOn = false;
      });
    }

    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _setupCameraController(_selectedCameraIndex);

    setState(() {
      _isFrontCamera = _cameras![_selectedCameraIndex].lensDirection ==
          CameraLensDirection.front;
    });

    HapticFeedback.lightImpact();
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
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        context.read<TfLiteModelServices>().status ==
            ModelPredictionStatus.predicting) {
      // Disable focus during prediction
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
      _showSnackBar("Failed to set focus.", backgroundColor: Colors.red);
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
      _resetDetectionState();
      return;
    }

    try {
      final File image = File(imageFile.path);

      if (!await image.exists()) {
        throw Exception("Image file does not exist");
      }

      final Map<String, dynamic>? result =
          await tfliteModelServices.predictImage(image);
      if (!mounted) {
        debugPrint(
            "Widget disposed during prediction, skipping result processing");
        return;
      }
      if (result != null) {
        final String detectedLabel = result['label'];
        final double confidence = result['confidence'];
        final bool isLikelyCrop = result['isLikelyCrop'] ?? false;

        // Handle non-crop detection
        if (!isLikelyCrop || detectedLabel == "Not a crop") {
          _showNonCropDialog();
          _resetDetectionState();
          return;
        }

        // Handle low confidence crop detection
        if (!result['isConfident']) {
          _showLowConfidenceDialog(detectedLabel, confidence);
          _resetDetectionState();
          return;
        }
        // Use helper for state updates
        _setDetectionState(
          showFeedback: true,
          detectedCrop: detectedLabel,
          confidence: confidence,
        );

        await Future.delayed(_detectionFeedbackDuration);
        if (mounted) {
          await _navigateToResults(
            detectedLabel,
            confidence,
            imageFile.path,
          );
        }
      } else {
        if (mounted) {
          _showErrorDialog("Detection failed. Please try again.");
        }
      }
    } catch (e) {
      debugPrint("Error during detection: $e");
      _showErrorDialog("Failed to process image: ${_sanitizeError(e)}");
    } finally {
      if (mounted) {
        _resetDetectionState();
      }
    }
  }

  void _showNonCropDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text("Not a Crop"),
            ],
          ),
          content: Text(
            "The image doesn't appear to contain a recognizable crop. Please take a clear photo of a crop leaf or plant.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showLowConfidenceDialog(String detectedLabel, double confidence) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text("Low Confidence"),
            ],
          ),
          content: Text(
            "Detected: $detectedLabel (${(confidence * 100).toStringAsFixed(1)}%)\n\n"
            "The confidence is low. Try taking a clearer photo with better lighting and focus on the crop leaves.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _captureImage() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        context.read<TfLiteModelServices>().status ==
            ModelPredictionStatus.predicting ||
        _isCapturing) {
      debugPrint(
        "Capture blocked: camera not ready or capture in progress",
      );
      return;
    }
    if (!_cameraController!.value.isPreviewPaused) {
      try {
        await _cameraController!.resumePreview();
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        debugPrint("Error resuming preview before capture: $e");
      }
    }
    _isCapturing = true;

    try {
      _captureAnimationController.forward().then((_) {
        _captureAnimationController.reverse();
      });

      HapticFeedback.heavyImpact();

      final imageFile = await _cameraController!.takePicture();
      debugPrint("Image captured: ${imageFile.path}");

      //validate image file
      final file = File(imageFile.path);
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint("✅ Image file validated - Size: $fileSize bytes");
      } else {
        debugPrint("❌ Error: Captured image file does not exist!");
      }

      await _performDetection(imageFile);
    } catch (e) {
      debugPrint("Error taking picture: $e");
      _showErrorDialog("Failed to capture image: ${_sanitizeError(e)}");
      _resetDetectionState();
    } finally {
      _isCapturing = false;
    }
  }

  bool _isCapturing = false;

  void _openGallery() async {
    HapticFeedback.lightImpact();
    final tfliteService = context.read<TfLiteModelServices>();

    if (tfliteService.status == ModelPredictionStatus.predicting) {
      _showSnackBar("Please wait, detection is in progress.");
      return;
    }

    _isPickingFromGallery = true;

    final ImagePicker imagePicker = ImagePicker();
    XFile? image;
    try {
      image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        debugPrint("Image selected: ${image.path}");
        await _performDetection(image);
      } else {
        _showSnackBar("Image selection cancelled");
      }
    } catch (e) {
      debugPrint("Error picking image from gallery: $e");
      _showErrorDialog("Failed to pick image from gallery.");
      _resetDetectionState();
    } finally {
      _isPickingFromGallery = false;

      if (_cameraController?.value.isInitialized == true) {
        try {
          if (_cameraController!.value.isPreviewPaused) {
            await _cameraController!.resumePreview();
            debugPrint("✅ Preview resumed after gallery");
          }
        } catch (e) {
          debugPrint("Warning: Could not resume preview after gallery: $e");
          // If resume fails, mark for reinitialization on next camera access
          _hasPermission = false;
        }
      }
    }
  }

  void _goBackToHome() {
    debugPrint("🔙 Going back to home screen");
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.navigateToTab(0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("App lifecycle state changed to: $state");

    switch (state) {
      case AppLifecycleState.inactive:
        // Only pause if not picking from gallery
        if (!_isPickingFromGallery) {
          debugPrint("App inactive - pausing preview");
          try {
            _cameraController?.pausePreview();
          } catch (e) {
            debugPrint("Error pausing preview on inactive: $e");
          }
        }
        break;
      case AppLifecycleState.paused:
        // Only dispose on real pause (not gallery activity)
        if (!_isPickingFromGallery) {
          debugPrint("App paused - disposing camera to prevent buffer leak");
          _disposeCamera();
        }
        break;

      case AppLifecycleState.resumed:
        debugPrint("App resumed - checking camera state");
        // Don't immediately reinitialize if coming back from gallery
        if (!_isPickingFromGallery && _hasPermission && mounted) {
          if (_cameraController == null ||
              !_cameraController!.value.isInitialized) {
            debugPrint("Camera needs reinitialization");
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _hasPermission && !_isPickingFromGallery) {
                _initilizeCameraComponents();
              }
            });
          } else {
            debugPrint("Resuming existing camera");
            try {
              _cameraController?.resumePreview();
            } catch (e) {
              debugPrint("Error resuming preview, will reinitialize: $e");
              _hasPermission = false; // Mark for reinitialization
            }
          }
        }
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        debugPrint("App detached/hidden, disposing camera...");
        _disposeCamera();
        break;
    }
  }

  @override
  void dispose() {
    debugPrint("🔄 Disposing camera resources...");

    // Dispose camera synchronously for hot reload safety
    _disposeCamera();

    try {
      _focusAnimationController.dispose();
      _captureAnimationController.dispose();
    } catch (e) {
      debugPrint("Error disposing animation controllers: $e");
    }

    WidgetsBinding.instance.removeObserver(this);
    _restoreOrientation();

    debugPrint("✅ Camera resources disposed");
    super.dispose();
  }

  void _disposeCamera() {
    if (_cameraController != null) {
      try {
        debugPrint("🗑️ Disposing camera controller...");

        // Stop preview first to clear buffers
        _cameraController?.pausePreview();

        Future.microtask(() async {
          try {
            // Force buffer cleanup by setting to null resolution briefly
            await _cameraController?.setZoomLevel(1.0);
          } catch (e) {
            debugPrint("Buffer cleanup warning: $e");
          }
        });

        // CRITICAL FIX: Synchronous disposal to prevent state conflicts
        _cameraController?.dispose();
        _cameraController = null;

        // Reset camera-related state only if widget is still mounted
        if (mounted) {
          setState(() {
            _currentZoomLevel = 1.0;
            _isFlashOn = false;
            _focusPoint = null;
          });
        }

        debugPrint("✅ Camera controller disposed successfully");
      } catch (e) {
        debugPrint("Error during camera disposal: $e");
        _cameraController = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TfLiteModelServices>(
      builder: (context, tfliteService, child) {
        return _buildCameraInterface(tfliteService);
      },
    );
  }

  // NEW HELPER METHODS ADDED BELOW THIS LINE

  Widget _buildCameraInterface(TfLiteModelServices tfliteService) {
    final mlStatus = tfliteService.status;
    final isCameraAndModelReady = _hasPermission &&
        _cameraController?.value.isInitialized == true &&
        (mlStatus == ModelPredictionStatus.ready ||
            mlStatus == ModelPredictionStatus.predicting);

    if (!isCameraAndModelReady) {
      return _buildLoadingInterface(tfliteService);
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

            // UI Overlays
            _buildDetectionFrame(),
            if (_focusPoint != null) _buildFocusRing(),

            // Camera Controls
            CameraOverlayWidget(
              isTop: true,
              onClose: _goBackToHome,
              onFlashToggle: _toggleFlash,
              isFlashOn: _isFlashOn,
              isControlsDisabled: mlStatus == ModelPredictionStatus.predicting,
            ),
            CameraOverlayWidget(
              isTop: false,
              onCapture: _captureImage,
              onGallery: _openGallery,
              onFlipCamera: _flipCamera,
              captureAnimation: _captureAnimation,
              isControlsDisabled: mlStatus == ModelPredictionStatus.predicting,
            ),

            // Detection Feedback
            if (_showDetectionFeedback &&
                mlStatus == ModelPredictionStatus.ready)
              DetectionFeedbackWidget(
                cropName: _detectedCrop,
                confidence: _confidence,
              ),

            // Loading Overlay - show if _isDetecting (ML prediction in progress)
            // or if the ML model is currently loading/predicting via its status
            if (mlStatus == ModelPredictionStatus.predicting ||
                mlStatus == ModelPredictionStatus.loading)
              const Enhancedloadingoverlay(
                minimumDuration: Duration(seconds: 3),
              ),
            // Zoom Indicator
            if (_currentZoomLevel > 1.0) _buildZoomIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingInterface(TfLiteModelServices tfliteService) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_cameraController?.value.isInitialized == true)
              Opacity(
                opacity: 0.3,
                child: CameraPreviewWidget(
                  isFrontCamera: _isFrontCamera,
                  zoomLevel: _currentZoomLevel,
                  onTapToFocus: (_) {},
                  onPinchToZoom: (_) {},
                  controller: _cameraController,
                ),
              ),

            // Overlay with loading content
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: _buildLoadingContent(tfliteService),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent(TfLiteModelServices tfliteService) {
    final mlStatus = tfliteService.status;

    if (!_hasPermission) {
      return _buildPermissionContent();
    } else if (mlStatus == ModelPredictionStatus.loading ||
        mlStatus == ModelPredictionStatus.initial) {
      // Add initial status check here
      return _buildModelLoadingContent();
    } else if (mlStatus == ModelPredictionStatus.error) {
      return _buildErrorContent(tfliteService);
    } else if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      //  permissions are granted and model might be ready,
      // but camera itself is still initializing or failed to initialize.
      return _buildCameraInitializingContent();
    } else {
      // should not be reached if all states are covered
      return const CircularProgressIndicator();
    }
  }

  Widget _buildPermissionContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
          onPressed: _retryPermissions, // Use the new retry method
          child: const Text('Grant Permissions'),
        ),
        SizedBox(height: 1.h), // Add some space
        TextButton(
          // Add a button to open settings directly
          onPressed: () {
            openAppSettings();
          },
          child: const Text('Open App Settings'),
        ),
      ],
    );
  }

  Widget _buildModelLoadingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary),
        ),
        SizedBox(height: 2.h),
        Text(
          'Loading crop detection model...',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorContent(TfLiteModelServices tfliteService) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 64),
        SizedBox(height: 2.h),
        Text(
          'Model loading error',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          tfliteService.errorMessage ??
              'An unknown error occurred while loading the model.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        ElevatedButton(
          onPressed: () {
            // Attempt to reload model and camera again
            initializeCameraOnDemand();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildCameraInitializingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // More user-friendly loading indicator
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          'Starting camera...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Please wait a moment',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Modified existing helper methods to use new constants
  Widget _buildDetectionFrame() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary
                .withOpacity(0.8), // changed from .withValues
            width: 2.0,
          ),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: _detectionFrameHorizontalMargin
              .w, // Changed to use constant with sizer
          vertical: _detectionFrameVerticalMargin
              .h, // Changed to use constant with sizer
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

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
    ]);
  }
}
