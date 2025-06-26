import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FarmingAlertCardWidget extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onLongPress;

  const FarmingAlertCardWidget({
    super.key,
    required this.alert,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final String title = alert["title"] as String;
    final String message = alert["message"] as String;
    final String priority = alert["priority"] as String;
    final String type = alert["type"] as String;
    final DateTime timestamp = alert["timestamp"] as DateTime;
    final bool isRead = alert["isRead"] as bool;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isRead
              ? AppTheme.lightTheme.colorScheme.surface
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: _getPriorityColor(priority),
            width: isRead ? 1.0 : 2.0,
          ),
          boxShadow: isRead
              ? null
              : [
                  BoxShadow(
                    color: _getPriorityColor(priority).withValues(alpha: 0.6),
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Priority indicator and icon
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getPriorityColor(priority).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getTypeIcon(type),
                  color: _getPriorityColor(priority),
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 3.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and priority badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.bold,
                            color: isRead
                                ? AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant
                                : AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          priority.toUpperCase(),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),

                  // Message
                  Text(
                    message,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isRead
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),

                  // Timestamp and read status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTimeAgo(timestamp),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Read status indicator
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            shape: BoxShape.circle,
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      case 'high':
        return Colors.orange;
      case 'medium':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'low':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'irrigation':
        return 'water_drop';
      case 'weather':
        return 'wb_cloudy';
      case 'fertilizer':
        return 'eco';
      case 'pest':
        return 'bug_report';
      case 'disease':
        return 'healing';
      case 'harvest':
        return 'agriculture';
      default:
        return 'notifications';
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
