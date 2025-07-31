import 'package:camera/camera.dart';
import 'package:cropscan_pro/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;
  final bool isFrontCamera;
  final double zoomLevel;
  final Function(Offset) onTapToFocus;
  final Function(double) onPinchToZoom;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.isFrontCamera,
    required this.zoomLevel,
    required this.onTapToFocus,
    required this.onPinchToZoom,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
      );
    }
    final screenSize = MediaQuery.of(context).size;
    final cameraAspectRatio = controller!.value.aspectRatio;
    // final screenAspectRatio = screenSize.width / screenSize.height;

    return GestureDetector(
        onTapDown: (details) {
          onTapToFocus.call(details.localPosition);
        },
        onScaleUpdate: (details) {
          onPinchToZoom.call(details.scale);
        },
        child: Container(
          color: Colors.black,
          width: screenSize.width,
          height: screenSize.height,
          child: ClipRRect(
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: SizedBox(
                  height: screenSize.width / cameraAspectRatio,
                  child: Transform.scale(
                    scale: zoomLevel,
                    alignment: Alignment.center,
                    child: CameraPreview(controller!),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
