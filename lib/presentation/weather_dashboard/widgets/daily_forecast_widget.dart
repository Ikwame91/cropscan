import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dailyData;

  const DailyForecastWidget({
    super.key,
    required this.dailyData,
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
      case 'heavy rain':
        return 'grain';
      default:
        return 'wb_sunny';
    }
  }

  Color _getUVIndexColor(int uvIndex) {
    if (uvIndex <= 2) {
      return Colors.green;
    } else if (uvIndex <= 5) {
      return Colors.yellow[700]!;
    } else if (uvIndex <= 7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: dailyData.asMap().entries.map((entry) {
            final index = entry.key;
            final dayData = entry.value;
            return Column(
              children: [
                _buildDailyForecastItem(dayData),
                if (index < dailyData.length - 1)
                  Divider(
                    height: 3.h,
                    color: AppTheme.lightTheme.dividerColor,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDailyForecastItem(Map<String, dynamic> dayData) {
    return InkWell(
      onTap: () {
        // Show detailed forecast
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
        child: Row(
          children: [
            // Day and date
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayData["day"] ?? "",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dayData["date"] ?? "",
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Weather icon and condition
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: _getWeatherIcon(dayData["icon"] ?? "sunny"),
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 32,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    dayData["condition"] ?? "",
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Temperature range
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${dayData["highTemp"] ?? 0}°',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${dayData["lowTemp"] ?? 0}°',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 4.w),

            // Farming details
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Humidity and UV
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'water_drop',
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.7),
                            size: 16,
                          ),
                          Text(
                            '${dayData["humidity"] ?? 0}%',
                            style: AppTheme.lightTheme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'wb_sunny',
                            color: _getUVIndexColor(dayData["uvIndex"] ?? 0),
                            size: 16,
                          ),
                          Text(
                            '${dayData["uvIndex"] ?? 0}',
                            style: AppTheme.lightTheme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  // Precipitation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'grain',
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.7),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${dayData["precipitation"] ?? 0}%',
                        style: AppTheme.lightTheme.textTheme.labelSmall,
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
}
