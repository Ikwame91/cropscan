import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraPreviewWidget extends StatelessWidget {
  final bool isFrontCamera;
  final double zoomLevel;
  final Function(Offset) onTapToFocus;
  final Function(double) onPinchToZoom;

  const CameraPreviewWidget({
    super.key,
    required this.isFrontCamera,
    required this.zoomLevel,
    required this.onTapToFocus,
    required this.onPinchToZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTapDown: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.globalPosition);
          onTapToFocus(localPosition);
        },
        onScaleUpdate: (details) {
          onPinchToZoom(details.scale);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.3),
                Colors.green.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Mock camera preview background
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87,
                child: CustomImageWidget(
                  imageUrl: isFrontCamera
                      ? 'https://images.pexels.com/photos/1459505/pexels-photo-1459505.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                      : 'https://images.pexels.com/photos/1459505/pexels-photo-1459505.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Crop detection indicators
              _buildDetectionIndicators(),

              // Grid lines for composition
              _buildGridLines(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionIndicators() {
    return Stack(
      children: [
        // Bell Pepper detection
        Positioned(
          left: 40.w,
          top: 30.h,
          child: _buildDetectionLabel('Bell Pepper', 0.92),
        ),

        // Tomato detection
        Positioned(
          right: 35.w,
          top: 50.h,
          child: _buildDetectionLabel('Tomato', 0.87),
        ),

        // Maize detection
        Positioned(
          left: 30.w,
          bottom: 30.h,
          child: _buildDetectionLabel('Maize', 0.94),
        ),
      ],
    );
  }

  Widget _buildDetectionLabel(String cropName, double confidence) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cropName,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${(confidence * 100).toInt()}%',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLines() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: GridPainter(),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
