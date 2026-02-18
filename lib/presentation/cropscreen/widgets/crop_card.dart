// Replace your crop_card.dart with these specific fixes:
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cropscan_pro/core/app_export.dart';
import 'package:cropscan_pro/models/crop_detection.dart';

class CropCard extends StatelessWidget {
  final CropDetection detection; // ✅ FIX: Use real detection data
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const CropCard({
    super.key,
    required this.detection,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = detection.status.toLowerCase().contains("healthy");
    final Color statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ✅ FIX: Cleaner Image Section - Remove confidence badge
            Stack(
              children: [
                _buildCropImage(),

                // Status Badge (Keep only this one)
                Positioned(
                  top: 2.w,
                  right: 2.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ✅ FIX: REMOVED confidence badge for cleaner look
              ],
            ),

            // Content Section
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          detection.cropName, // ✅ Real crop name
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onAction != null)
                        GestureDetector(
                          onTap: onAction,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.lightTheme.dividerColor,
                              ),
                            ),
                            child: CustomIconWidget(
                              iconName: 'more_vert',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Disease/Status Information
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: statusColor,
                          size: 20,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                detection.status, // ✅ Real status
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Useful Statistics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        iconName: 'analytics',
                        label: 'Confidence',
                        value:
                            '${(detection.confidence * 100).toStringAsFixed(1)}%',
                        color: _getConfidenceColor(),
                      ),
                      _buildInfoChip(
                        iconName: 'access_time',
                        label: 'Detected',
                        value: _getTimeAgo(),
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      _buildInfoChip(
                        iconData:
                            _getPriorityIcon(), // ✅ FIX: Use iconData parameter
                        label: 'Priority',
                        value: _getPriorityLevel(),
                        color: _getPriorityColor(),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Action Recommendations
                  if (!isHealthy) ...[
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              _getActionRecommendation(), // ✅ Now with better message
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],

                  // ✅ FIX: Cleaner Footer Row - Just timestamp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Last scanned',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _formatDate(), // ✅ Now shows "X hours ago" format
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper Methods for Real Data
  Color _getStatusColor() {
    final statusLower = detection.status.toLowerCase();

    if (statusLower.contains('healthy')) {
      return Colors.green;
    } else if (statusLower.contains('disease') ||
        statusLower.contains('virus') ||
        statusLower.contains('blight')) {
      return Colors.red;
    } else if (statusLower.contains('pest') || statusLower.contains('insect')) {
      return Colors.orange;
    } else if (statusLower.contains('deficiency')) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }

  String _getStatusText() {
    final statusLower = detection.status.toLowerCase();

    if (statusLower.contains('healthy')) {
      return 'Healthy';
    } else if (statusLower.contains('disease') ||
        statusLower.contains('virus')) {
      return 'Disease Detected';
    } else if (statusLower.contains('pest')) {
      return 'Pest Issue';
    } else {
      return 'Needs Attention';
    }
  }

  IconData _getStatusIcon() {
    final statusLower = detection.status.toLowerCase();

    if (statusLower.contains('healthy')) {
      return Icons.check_circle;
    } else if (statusLower.contains('disease') ||
        statusLower.contains('virus')) {
      return Icons.coronavirus;
    } else if (statusLower.contains('pest')) {
      return Icons.bug_report;
    } else {
      return Icons.warning;
    }
  }

  Color _getConfidenceColor() {
    if (detection.confidence >= 0.8) return Colors.green;
    if (detection.confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final diff = now.difference(detection.detectedAt);

    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hour(s) ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  String _getPriorityLevel() {
    final statusLower = detection.status.toLowerCase();

    if (statusLower.contains('healthy')) return 'Low';
    if (statusLower.contains('disease') || statusLower.contains('virus')) {
      return 'High';
    }
    if (statusLower.contains('pest')) return 'Medium';
    return 'Medium';
  }

  Color _getPriorityColor() {
    final priority = _getPriorityLevel();
    switch (priority) {
      case 'High':
        return const Color.fromARGB(255, 243, 147, 140);
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon() {
    final priority = _getPriorityLevel();
    switch (priority) {
      case 'High':
        return Icons.priority_high;
      case 'Medium':
        return Icons.warning;
      case 'Low':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getActionRecommendation() {
    final statusLower = detection.status.toLowerCase();

    if (statusLower.contains('bacterial')) {
      return 'Apply copper-based fungicide. Remove affected leaves.';
    } else if (statusLower.contains('virus')) {
      return 'Remove infected plants. Control insect vectors.';
    } else if (statusLower.contains('blight')) {
      return 'Improve air circulation. Apply appropriate fungicide.';
    } else if (statusLower.contains('pest')) {
      return 'Apply organic pesticide. Monitor regularly.';
    } else {
      // ✅ FIX: Remove "consult agricultural expert" message
      return 'Monitor crop health and apply preventive measures.';
    }
  }

  String _formatDate() {
    // ✅ FIX: Back to the better time ago format
    final now = DateTime.now();
    final diff = now.difference(detection.detectedAt);

    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  Widget _buildCropImage() {
    try {
      final imageFile = File(detection.imageUrl);
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          width: double.infinity,
          height: 20.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        );
      } else {
        return _buildPlaceholderImage();
      }
    } catch (e) {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 20.h,
      color: AppTheme.lightTheme.colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'image',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 40,
          ),
          SizedBox(height: 1.h),
          Text(
            'Image not available',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    String? iconName,
    IconData? iconData, // ✅ FIX: Add optional IconData parameter
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        // ✅ FIX: Handle both icon types
        if (iconData != null)
          Icon(
            iconData,
            color: color,
            size: 20,
          )
        else if (iconName != null)
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 20,
          )
        else
          Icon(
            Icons.info,
            color: color,
            size: 20,
          ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
