import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatisticsSummaryWidget extends StatelessWidget {
  final int totalScans;
  final String mostIdentifiedCrop;
  final double averageConfidence;

  const StatisticsSummaryWidget({
    super.key,
    required this.totalScans,
    required this.mostIdentifiedCrop,
    required this.averageConfidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'analytics',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Detection Summary',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              // Total Scans
              Expanded(
                child: _buildStatItem(
                  icon: 'camera_alt',
                  label: 'Total Scans',
                  value: totalScans.toString(),
                ),
              ),

              // Vertical Divider
              Container(
                height: 8.h,
                width: 1,
                color: AppTheme.lightTheme.colorScheme.onPrimary
                    .withValues(alpha: 0.3),
              ),

              // Most Identified
              Expanded(
                child: _buildStatItem(
                  icon: 'eco',
                  label: 'Top Crop',
                  value: mostIdentifiedCrop,
                ),
              ),

              // Vertical Divider
              Container(
                height: 8.h,
                width: 1,
                color: AppTheme.lightTheme.colorScheme.onPrimary
                    .withValues(alpha: 0.3),
              ),

              // Average Confidence
              Expanded(
                child: _buildStatItem(
                  icon: 'trending_up',
                  label: 'Avg. Accuracy',
                  value: '${(averageConfidence * 100).toInt()}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 28,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary
                .withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
