import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraOverlayWidget extends StatelessWidget {
  final bool isTop;
  final VoidCallback? onFlashToggle;
  final bool isFlashOn;
  final VoidCallback? onCapture;
  final VoidCallback? onGallery;
  final VoidCallback? onFlipCamera;
  final Animation<double>? captureAnimation;
  final bool isControlsDisabled;
  final VoidCallback? onClose;

  const CameraOverlayWidget({
    super.key,
    required this.isTop,
    this.onFlashToggle,
    this.isFlashOn = false,
    this.onCapture,
    this.onGallery,
    this.onFlipCamera,
    this.captureAnimation,
    this.isControlsDisabled = false,
    this.onClose,
  });
  @override
  Widget build(BuildContext context) {
    return isTop ? _buildTopOverlay(context) : _buildBottomOverlay(context);
  }

  Widget _buildTopOverlay(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 12.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopButton(
                icon: 'close',
                onPressed: isControlsDisabled
                    ? null
                    : onClose ?? () => Navigator.of(context).pop(),
              ),
              Text(
                'CropScan',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 25.sp,
                ),
              ),
              _buildTopButton(
                icon: isFlashOn == true ? 'flash_on' : 'flash_off',
                onPressed: isControlsDisabled ? null : onFlashToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 20.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBottomButton(
                icon: 'photo_library',
                onPressed: isControlsDisabled ? null : onGallery,
              ),
              _buildCaptureButton(context),
              _buildBottomButton(
                icon: 'flip_camera_ios',
                onPressed: isControlsDisabled ? null : onFlipCamera,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required String icon,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 6.w,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required String icon,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 7.w,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton(BuildContext context) {
    Widget button = GestureDetector(
      onTap: onCapture,
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'camera_alt',
            color: Colors.white,
            size: 8.w,
          ),
        ),
      ),
    );

    if (captureAnimation != null) {
      return AnimatedBuilder(
        animation: captureAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: captureAnimation!.value,
            child: button,
          );
        },
      );
    }

    return button;
  }
}
