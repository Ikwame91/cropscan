import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentDetectionCardWidget extends StatelessWidget {
  final Map<String, dynamic> detection;
  final VoidCallback onTap;

  const RecentDetectionCardWidget({
    super.key,
    required this.detection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String cropName = detection["cropName"] as String;
    final double confidence = detection["confidence"] as double;
    final String imageUrl = detection["imageUrl"] as String;
    final DateTime detectedAt = detection["detectedAt"] as DateTime;
    final String status = detection["status"] as String;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              child: SizedBox(
                width: double.infinity,
                height: 12.h,
                child: CustomImageWidget(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 15.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(7.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Crop name and confidence
                    Text(
                      cropName,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),

                    // Confidence score
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'verified',
                          color: _getConfidenceColor(confidence),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            '${confidence.toStringAsFixed(1)}%',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: _getConfidenceColor(confidence),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    // Status
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        status,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Time ago
                    Text(
                      _getTimeAgo(detectedAt),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontSize: 9.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 90) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (confidence >= 70) {
      return Colors.orange;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'disease detected':
        return AppTheme.lightTheme.colorScheme.error;
      case 'pest detected':
        return Colors.orange;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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
}



///rechecked