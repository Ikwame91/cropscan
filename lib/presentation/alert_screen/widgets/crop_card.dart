import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cropscan_pro/core/app_export.dart'; // AppTheme, CustomIconWidget

class CropCard extends StatelessWidget {
  final Map<String, dynamic> crop;

  const CropCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = crop["status"] == "Healthy"
        ? AppTheme.lightTheme.colorScheme.primary
        : AppTheme.lightTheme.colorScheme.error;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      child: Column(
        children: [
          CustomImageWidget(
            imageUrl: crop["imageUrl"],
            width: double.infinity, // Take full width
            height: 20.h, // Adjust height as needed
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      crop["cropName"],
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'refresh',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  crop["location"],
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(
                      iconName: 'monitor_heart', // Or health icon
                      label: 'Health',
                      value: '${crop["health"]}%',
                      color: statusColor,
                    ),
                    _buildInfoChip(
                      iconName: 'calendar_today', // Harvest icon
                      label: 'Harvest',
                      value: '${crop["harvestInDays"]} days',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                    ),
                    _buildInfoChip(
                      iconName: 'warning', // Issues icon
                      label: 'Issues',
                      value: '${crop["issues"]}',
                      color: crop["issues"] > 0
                          ? AppTheme.lightTheme.colorScheme.error
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expected: ${crop["expectedYield"].toStringAsFixed(1)} tons',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Scanned ${crop["scannedAgo"]}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the info chips (Health, Harvest, Issues)
  Widget _buildInfoChip({
    required String iconName,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
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
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
