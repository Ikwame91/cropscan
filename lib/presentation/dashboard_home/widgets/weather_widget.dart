import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock weather data
    final Map<String, dynamic> weatherData = {
      "location": "Pune, Maharashtra",
      "temperature": 28,
      "condition": "Partly Cloudy",
      "humidity": 65,
      "windSpeed": 12,
      "uvIndex": 6,
      "forecast": [
        {"day": "Today", "high": 30, "low": 22, "condition": "sunny"},
        {"day": "Tomorrow", "high": 32, "low": 24, "condition": "cloudy"},
        {"day": "Wed", "high": 29, "low": 21, "condition": "rainy"},
      ]
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        weatherData["location"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/weather-dashboard'),
                child: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Current weather
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Temperature and condition
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weatherData["temperature"]}°C',
                      style:
                          AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      weatherData["condition"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary
                            .withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Weather icon
              Expanded(
                flex: 1,
                child: Container(
                  height: 15.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'wb_cloudy',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Weather details
          Row(
            children: [
              Expanded(
                child: _buildWeatherDetail(
                  'humidity',
                  'Humidity',
                  '${weatherData["humidity"]}%',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildWeatherDetail(
                  'air',
                  'Wind',
                  '${weatherData["windSpeed"]} km/h',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildWeatherDetail(
                  'wb_sunny',
                  'UV Index',
                  '${weatherData["uvIndex"]}',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Forecast
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onPrimary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: (weatherData["forecast"] as List).map((forecast) {
                return Column(
                  children: [
                    Text(
                      forecast["day"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary
                            .withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    CustomIconWidget(
                      iconName:
                          _getWeatherIcon(forecast["condition"] as String),
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '${forecast["high"]}°/${forecast["low"]}°',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String iconName, String label, String value) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color:
              AppTheme.lightTheme.colorScheme.onPrimary.withValues(alpha: 0.8),
          size: 20,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary
                .withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return 'wb_sunny';
      case 'cloudy':
        return 'wb_cloudy';
      case 'rainy':
        return 'grain';
      default:
        return 'wb_sunny';
    }
  }
}
