import 'dart:io';

import 'package:cropscan_pro/models/crop_detection.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentDetectionCardWidget extends StatelessWidget {
  final CropDetection detection;
  final VoidCallback onTap;

  const RecentDetectionCardWidget({
    super.key,
    required this.detection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75.w,
      child: Card(
        elevation: AppTheme.lightTheme.cardTheme.elevation,
        shape: AppTheme.lightTheme.cardTheme.shape,
        color: AppTheme.lightTheme.cardTheme.color,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 12.h,
                    width: double.infinity,
                    child: _buildImage(),
                  ),
                ),
                SizedBox(height: 1.5.h),

                Flexible(
                  child: Text(
                    detection.cropName,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 0.8.h),

                // Flexible(
                //   child: Row(
                //     children: [
                //       Flexible(
                //         child: Container(
                //           padding: EdgeInsets.symmetric(
                //               horizontal: 2.w,
                //               vertical: 0.4.h),
                //           decoration: BoxDecoration(
                //             color: _getStatusColor().withValues(alpha: 0.1),
                //             borderRadius: BorderRadius.circular(12),
                //             border: Border.all(
                //               color: _getStatusColor(),
                //               width: 1,
                //             ),
                //           ),
                //           child: Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               Icon(
                //                 _getStatusIcon(),
                //                 color: _getStatusColor(),
                //                 size: 10,
                //               ),
                //               SizedBox(width: 1.w),
                //               Flexible(
                //                 child: Text(
                //                   '${(detection.confidence * 100).toStringAsFixed(1)}%',
                //                   style: AppTheme
                //                       .lightTheme.textTheme.labelSmall
                //                       ?.copyWith(
                //                     color: _getStatusColor(),
                //                     fontWeight: FontWeight.w600,
                //                     fontSize: 10.sp,
                //                   ),
                //                   overflow: TextOverflow.ellipsis,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 0.8.h),

                Flexible(
                  child: Text(
                    detection.status,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 0.8.h),

                Flexible(
                  child: Text(
                    _formatTimestamp(),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontSize: 10.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    final statusLower = detection.status.toLowerCase();

    if (statusLower.contains('disease') ||
        statusLower.contains('virus') ||
        statusLower.contains('blight') ||
        statusLower.contains('spot') ||
        statusLower.contains('rust') ||
        statusLower.contains('deficiency')) {
      return Colors.red;
    } else if (statusLower.contains('pest') || statusLower.contains('insect')) {
      return Colors.orange;
    } else if (statusLower.contains('healthy')) {
      return AppTheme.getSuccessColor(true);
    }

    if (detection.confidence >= 0.8) {
      return AppTheme.getSuccessColor(true);
    } else if (detection.confidence >= 0.6) {
      return AppTheme.getWarningColor(true);
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  // IconData _getStatusIcon() {
  //   final statusLower = detection.status.toLowerCase();

  //   if (statusLower.contains('disease') ||
  //       statusLower.contains('virus') ||
  //       statusLower.contains('blight') ||
  //       statusLower.contains('spot') ||
  //       statusLower.contains('rust')) {
  //     return Icons.coronavirus;
  //   } else if (statusLower.contains('pest') || statusLower.contains('insect')) {
  //     return Icons.bug_report;
  //   } else if (statusLower.contains('healthy')) {
  //     return Icons.check_circle;
  //   } else if (statusLower.contains('deficiency')) {
  //     return Icons.warning;
  //   }

  //   if (detection.confidence >= 0.8) {
  //     return Icons.check_circle;
  //   } else if (detection.confidence >= 0.6) {
  //     return Icons.warning;
  //   } else {
  //     return Icons.error;
  //   }
  // }

  String _formatTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(detection.detectedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildImage() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    try {
      final imageFile = File(detection.imageUrl);

      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Error loading image from file: $error");
            return _buildPlaceholderImage();
          },
        );
      } else {
        debugPrint("Image file does not exist: ${detection.imageUrl}");
        return _buildPlaceholderImage();
      }
    } catch (e) {
      debugPrint("Exception loading image: $e");
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.lightTheme.colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'image',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          SizedBox(height: 0.5.h),
          Flexible(
            child: Text(
              'Image unavailable',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 9.sp,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
