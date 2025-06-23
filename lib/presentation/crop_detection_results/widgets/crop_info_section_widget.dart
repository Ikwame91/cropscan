import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './expandable_info_card_widget.dart';

class CropInfoSectionWidget extends StatelessWidget {
  final Map<String, dynamic> cropInfo;

  const CropInfoSectionWidget({
    super.key,
    required this.cropInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop Information',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Scientific Information Card
          Card(
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
                        iconName: 'science',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Scientific Classification',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildInfoRow('Scientific Name',
                      cropInfo["scientificName"] as String? ?? 'Unknown'),
                  SizedBox(height: 1.h),
                  _buildInfoRow(
                      'Family', cropInfo["family"] as String? ?? 'Unknown'),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Growing Tips
          ExpandableInfoCardWidget(
            title: 'Growing Tips',
            icon: 'tips_and_updates',
            items: (cropInfo["growingTips"] as List?)?.cast<String>() ?? [],
            color: AppTheme.getSuccessColor(true),
          ),

          SizedBox(height: 2.h),

          // Seasonal Recommendations
          ExpandableInfoCardWidget(
            title: 'Seasonal Recommendations',
            icon: 'calendar_month',
            items: (cropInfo["seasonalRecommendations"] as List?)
                    ?.cast<String>() ??
                [],
            color: AppTheme.lightTheme.colorScheme.primary,
          ),

          SizedBox(height: 2.h),

          // Disease Warnings
          ExpandableInfoCardWidget(
            title: 'Disease Warnings',
            icon: 'warning',
            items: (cropInfo["diseaseWarnings"] as List?)?.cast<String>() ?? [],
            color: AppTheme.getWarningColor(true),
          ),

          SizedBox(height: 2.h),

          // Pest Alerts
          ExpandableInfoCardWidget(
            title: 'Pest Alerts',
            icon: 'bug_report',
            items: (cropInfo["pestAlerts"] as List?)?.cast<String>() ?? [],
            color: AppTheme.lightTheme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            '$label:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
