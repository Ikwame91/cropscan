import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrentWeatherCardWidget extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final bool isRefreshing;

  const CurrentWeatherCardWidget({
    super.key,
    required this.weatherData,
    required this.isRefreshing,
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

  String _formatLastUpdated(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location and GPS accuracy
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    weatherData["location"] ?? "Unknown Location",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    weatherData["gpsAccuracy"] ?? "GPS",
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Main weather display
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temperature and condition
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weatherData["temperature"] ?? 0}',
                            style: AppTheme.lightTheme.textTheme.displayLarge
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w300,
                              fontSize: 64,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            '°C',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        weatherData["condition"] ?? "Unknown",
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Weather icon
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      isRefreshing
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                strokeWidth: 3,
                              ),
                            )
                          : CustomIconWidget(
                              iconName: _getWeatherIcon(
                                  weatherData["weatherIcon"] ?? "sunny"),
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              size: 80,
                            ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Weather details grid
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onPrimary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildWeatherDetail(
                          'Humidity',
                          '${weatherData["humidity"] ?? 0}%',
                          'water_drop',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 6.h,
                        color: AppTheme.lightTheme.colorScheme.onPrimary
                            .withValues(alpha: 0.2),
                      ),
                      Expanded(
                        child: _buildWeatherDetail(
                          'Wind Speed',
                          '${weatherData["windSpeed"] ?? 0} km/h',
                          'air',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.2),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildWeatherDetail(
                          'UV Index',
                          '${weatherData["uvIndex"] ?? 0}',
                          'wb_sunny',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 6.h,
                        color: AppTheme.lightTheme.colorScheme.onPrimary
                            .withValues(alpha: 0.2),
                      ),
                      Expanded(
                        child: _buildWeatherDetail(
                          'Precipitation',
                          '${weatherData["precipitation"] ?? 0}%',
                          'grain',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Last updated
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.lightTheme.colorScheme.onPrimary
                      .withValues(alpha: 0.7),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Updated ${_formatLastUpdated(weatherData["lastUpdated"] ?? DateTime.now())}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color:
              AppTheme.lightTheme.colorScheme.onPrimary.withValues(alpha: 0.8),
          size: 24,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary
                .withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
