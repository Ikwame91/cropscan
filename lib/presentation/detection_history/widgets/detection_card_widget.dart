import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DetectionCardWidget extends StatelessWidget {
  final Map<String, dynamic> detection;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onReidentify;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const DetectionCardWidget({
    super.key,
    required this.detection,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onReidentify,
    required this.onShare,
    required this.onDelete,
  });

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (confidence >= 0.7) {
      return Colors.orange;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  @override
  Widget build(BuildContext context) {
    final confidence = detection['confidence'] as double;
    final timestamp = detection['timestamp'] as DateTime;
    final diseaseDetected = detection['diseaseDetected'] as bool;
    final pestDetected = detection['pestDetected'] as bool;

    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      child: Dismissible(
        key: Key('detection_${detection['id']}'),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Re-identify',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          onReidentify();
          return false;
        },
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Card(
            elevation: isSelected ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Selection Checkbox
                  if (isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onTap(),
                      activeColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                  ],

                  // Crop Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: detection['imageUrl'] as String,
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(width: 4.w),

                  // Detection Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Crop Name and Type
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                detection['cropName'] as String,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme
                                    .lightTheme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                detection['cropType'] as String,
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1.h),

                        // Location and Timestamp
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                detection['location'] as String,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 0.5.h),

                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              _formatTimestamp(timestamp),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1.h),

                        // Alert Indicators
                        if (diseaseDetected || pestDetected) ...[
                          Row(
                            children: [
                              if (diseaseDetected) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightTheme.colorScheme.error
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'warning',
                                        color: AppTheme
                                            .lightTheme.colorScheme.error,
                                        size: 12,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Disease',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 2.w),
                              ],
                              if (pestDetected) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'bug_report',
                                        color: Colors.orange,
                                        size: 12,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Pest',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 1.h),
                        ],
                      ],
                    ),
                  ),

                  // Confidence Indicator
                  Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(confidence)
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getConfidenceColor(confidence),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${(confidence * 100).toInt()}%',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: _getConfidenceColor(confidence),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      if (!isSelectionMode) ...[
                        PopupMenuButton<String>(
                          icon: CustomIconWidget(
                            iconName: 'more_vert',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'reidentify':
                                onReidentify();
                                break;
                              case 'share':
                                onShare();
                                break;
                              case 'delete':
                                onDelete();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'reidentify',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'refresh',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    size: 18,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text('Re-identify'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'share',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    size: 18,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text('Share'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'delete',
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    size: 18,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
