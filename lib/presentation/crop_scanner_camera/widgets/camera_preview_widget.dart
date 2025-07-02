import 'package:camera/camera.dart';
import 'package:cropscan_pro/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
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
    if (!controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentDark,
          ),
        ),
      );
    }
    final size = MediaQuery.of(context).size;
    final aspectRatio = controller.value.aspectRatio;

    Widget cameraChild = CameraPreview(controller);

    //handling zoom transformation
    cameraChild = Transform.scale(
      scale: zoomLevel,
      alignment: Alignment.center,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: cameraChild,
        ),
      ),
    );
    return GestureDetector(
      onTapDown: (details) {
        onTapToFocus.call(details.localPosition);
      },
      onScaleUpdate: (details) {
        onPinchToZoom.call(details.scale);
      },

      child: ClipRRect(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.width / aspectRatio,
              child: cameraChild,
            ),
          ),
        ),
      ),
      // child: Container(
      //   width: double.infinity,
      //   height: double.infinity,
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //       colors: [
      //         Colors.green.withValues(alpha: 0.1),
      //         Colors.black.withValues(alpha: 0.3),
      //         Colors.green.withValues(alpha: 0.1),
      //       ],
      //     ),
      //   ),
      //   child: Stack(
      //     children: [
      //       // Mock camera preview background
      //       Container(
      //         width: double.infinity,
      //         height: double.infinity,
      //         color: Colors.black87,
      //         //////////////////////////////////////////phase 1 fix
      //         child: Image.asset(
      //           'assets/images/soil.jpg',
      //           fit: BoxFit.cover,
      //         ),
      //       ),

      //       // Crop detection indicators
      //       // _buildDetectionIndicators(),

      //       // Grid lines for composition
      //       // _buildGridLines(),
      //     ],
      //   ),
      // ),
    );
  }

  // Widget _buildDetectionIndicators() {
  //   return Stack(
  //     children: [
  //       // Bell Pepper detection
  //       Positioned(
  //         left: 40.w,
  //         top: 30.h,
  //         child: _buildDetectionLabel('Bell Pepper', 0.92),
  //       ),

  //       // Tomato detection
  //       Positioned(
  //         right: 35.w,
  //         top: 50.h,
  //         child: _buildDetectionLabel('Tomato', 0.87),
  //       ),

  //       // Maize detection
  //       Positioned(
  //         left: 30.w,
  //         bottom: 30.h,
  //         child: _buildDetectionLabel('Maize', 0.94),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildDetectionLabel(String cropName, double confidence) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
  //     decoration: BoxDecoration(
  //       color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.9),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: Colors.white.withValues(alpha: 0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text(
  //           cropName,
  //           style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
  //             color: Colors.white,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         Text(
  //           '${(confidence * 100).toInt()}%',
  //           style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
  //             color: Colors.white.withValues(alpha: 0.8),
  //             fontSize: 10.sp,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

//   Widget _buildGridLines() {
//     return SizedBox(
//       width: double.infinity,
//       height: double.infinity,
//       child: CustomPaint(
//         painter: GridPainter(),
//       ),
//     );
//   }
// }

// class GridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.3)
//       ..strokeWidth = 0.5;

//     // Vertical lines
//     canvas.drawLine(
//       Offset(size.width / 3, 0),
//       Offset(size.width / 3, size.height),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(2 * size.width / 3, 0),
//       Offset(2 * size.width / 3, size.height),
//       paint,
//     );

//     // Horizontal lines
//     canvas.drawLine(
//       Offset(0, size.height / 3),
//       Offset(size.width, size.height / 3),
//       paint,
//     );
//     canvas.drawLine(
//       Offset(0, 2 * size.height / 3),
//       Offset(size.width, 2 * size.height / 3),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
