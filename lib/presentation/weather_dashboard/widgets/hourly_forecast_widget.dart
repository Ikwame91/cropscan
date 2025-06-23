import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyData,
  });

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return 'wb_sunny';
      case 'partly_cloudy_day':
      case 'partly cloudy':
        return 'wb_cloudy';
      case 'cloudy':
        return 'cloud';
      case 'rainy':
        return 'grain';
      default:
        return 'wb_sunny';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        itemCount: hourlyData.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final hourData = hourlyData[index];
          return _buildHourlyCard(hourData);
        },
      ),
    );
  }

  Widget _buildHourlyCard(Map<String, dynamic> hourData) {
    return Container(
      width: 20.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Time
          Text(
            hourData["time"] ?? "",
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),

          // Weather icon
          CustomIconWidget(
            iconName: _getWeatherIcon(hourData["icon"] ?? "sunny"),
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 32,
          ),

          // Temperature
          Text(
            '${hourData["temperature"] ?? 0}°',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),

          // Precipitation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'grain',
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.7),
                size: 12,
              ),
              SizedBox(width: 1.w),
              Text(
                '${hourData["precipitation"] ?? 0}%',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          // Wind speed
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'air',
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.7),
                size: 12,
              ),
              SizedBox(width: 1.w),
              Text(
                '${hourData["windSpeed"] ?? 0}',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
