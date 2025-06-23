import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _isFrontCamera = false;
  double _zoomLevel = 1.0;
  bool _hasPermission = true;
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
    _initializeAnimations();
    _lockOrientation();
    _checkCameraPermission();
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

  void _checkCameraPermission() {
    // Mock permission check - in real app, use permission_handler package
    setState(() {
      _hasPermission = true;
    });
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    HapticFeedback.lightImpact();
  }

  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    HapticFeedback.lightImpact();
  }

  void _onTapToFocus(Offset position) {
    setState(() {
      _focusPoint = position;
    });

    _focusAnimationController.forward().then((_) {
      _focusAnimationController.reverse();
    });

    HapticFeedback.selectionClick();
  }

  void _onPinchToZoom(double scale) {
    setState(() {
      _zoomLevel = (scale * 1.0).clamp(1.0, 3.0);
    });
  }

  void _captureImage() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    _captureAnimationController.forward().then((_) {
      _captureAnimationController.reverse();
    });

    HapticFeedback.heavyImpact();

    // Simulate ML processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock detection result
    final detection = _mockDetections[
        DateTime.now().millisecondsSinceEpoch % _mockDetections.length];

    setState(() {
      _detectedCrop = detection['crop'];
      _confidence = detection['confidence'];
      _showDetectionFeedback = true;
    });

    // Auto-navigate after confirmation delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _showDetectionFeedback = false;
    });

    if (mounted) {
      Navigator.pushNamed(context, '/crop-detection-results');
    }
  }

  void _openGallery() {
    HapticFeedback.lightImpact();
    // In real app, implement image picker from gallery
    Navigator.pushNamed(context, '/crop-detection-results');
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
              width: 1.0,
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
