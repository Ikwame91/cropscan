import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DetectionResultCardWidget extends StatelessWidget {
  final String cropName;
  final double confidence;
  final DateTime timestamp;
  final Color? statusColor;
  final String? condition;

  const DetectionResultCardWidget({
    super.key,
    required this.cropName,
    required this.confidence,
    this.statusColor,
    this.condition,
    required this.timestamp,
  });

  Color _getConfidenceColor() {
    // ✅ FIX: Use provided statusColor if available, otherwise use confidence-based logic
    if (statusColor != null) {
      return statusColor!;
    }

    // ✅ FIX: Use actual confidence percentage (0-100 scale)
    if (confidence >= 0.8) {
      return AppTheme.getSuccessColor(true);
    } else if (confidence >= 0.6) {
      return AppTheme.getWarningColor(true);
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  String _getConfidenceText() {
    // ✅ FIX: Use actual confidence percentage
    if (confidence >= 0.8) {
      return 'High Confidence';
    } else if (confidence >= 0.6) {
      return 'Medium Confidence';
    } else {
      return 'Low Confidence';
    }
  }

  String _getConditionText() {
    return condition ?? _getConfidenceText();
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.lightTheme.cardTheme.elevation,
      shape: AppTheme.lightTheme.cardTheme.shape,
      color: AppTheme.lightTheme.cardTheme.color,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'eco',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Crop Identified',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Crop Name
            Text(
              cropName,
              style: GoogleFonts.poppins(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(height: 2.h),

            Row(
              children: [
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                //   decoration: BoxDecoration(
                //     color: _getConfidenceColor().withValues(alpha: 0.1),
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(
                //       color: _getConfidenceColor(),
                //       width: 1.5,
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       CustomIconWidget(
                //         iconName: confidence >= 0.8
                //             ? 'check_circle'
                //             : confidence >= 0.6
                //                 ? 'warning'
                //                 : 'error',
                //         color: _getConfidenceColor(),
                //         size: 16,
                //       ),
                //       SizedBox(width: 2.w),
                //       Text(
                //         // ✅ FIX: Display confidence as percentage properly
                //         '${(confidence * 100).toStringAsFixed(1)}%',
                //         style:
                //             AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                //           color: _getConfidenceColor(),
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(width: 3.w),
                Text(
                  _getConditionText(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: _getConfidenceColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Timestamp
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Detected ${_formatTimestamp()}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // ✅ FIX: Show warning for low confidence
            if (confidence < 0.7) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.getWarningColor(true).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        AppTheme.getWarningColor(true).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.getWarningColor(true),
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        confidence < 0.5
                            ? 'Very low confidence. Consider retaking with better lighting.'
                            : 'Moderate confidence. For best results, ensure good lighting and focus.',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.getWarningColor(true),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
