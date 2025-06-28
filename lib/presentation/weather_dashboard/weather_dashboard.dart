import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/current_weather_card_widget.dart';
import './widgets/daily_forecast_widget.dart';
import './widgets/farming_alerts_widget.dart';
import './widgets/hourly_forecast_widget.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  bool _isRefreshing = false;

  // Mock weather data
  final Map<String, dynamic> _currentWeather = {
    "temperature": 28,
    "condition": "Partly Cloudy",
    "location": "Farm Location, State",
    "humidity": 65,
    "windSpeed": 12,
    "uvIndex": 6,
    "precipitation": 20,
    "lastUpdated": DateTime.now().subtract(Duration(minutes: 15)),
    "gpsAccuracy": "High",
    "weatherIcon": "partly_cloudy_day"
  };

  final List<Map<String, dynamic>> _hourlyForecast = [
    {
      "time": "12 PM",
      "temperature": 28,
      "precipitation": 20,
      "windSpeed": 12,
      "icon": "sunny"
    },
    {
      "time": "1 PM",
      "temperature": 30,
      "precipitation": 15,
      "windSpeed": 14,
      "icon": "partly_cloudy_day"
    },
    {
      "time": "2 PM",
      "temperature": 32,
      "precipitation": 10,
      "windSpeed": 16,
      "icon": "sunny"
    },
    {
      "time": "3 PM",
      "temperature": 31,
      "precipitation": 25,
      "windSpeed": 18,
      "icon": "cloudy"
    },
    {
      "time": "4 PM",
      "temperature": 29,
      "precipitation": 40,
      "windSpeed": 20,
      "icon": "rainy"
    },
    {
      "time": "5 PM",
      "temperature": 27,
      "precipitation": 60,
      "windSpeed": 22,
      "icon": "rainy"
    }
  ];

  final List<Map<String, dynamic>> _dailyForecast = [
    {
      "day": "Today",
      "date": "Dec 15",
      "highTemp": 32,
      "lowTemp": 22,
      "condition": "Partly Cloudy",
      "humidity": 65,
      "uvIndex": 6,
      "precipitation": 20,
      "icon": "partly_cloudy_day"
    },
    {
      "day": "Tomorrow",
      "date": "Dec 16",
      "highTemp": 29,
      "lowTemp": 20,
      "condition": "Rainy",
      "humidity": 80,
      "uvIndex": 3,
      "precipitation": 75,
      "icon": "rainy"
    },
    {
      "day": "Wednesday",
      "date": "Dec 17",
      "highTemp": 26,
      "lowTemp": 18,
      "condition": "Heavy Rain",
      "humidity": 85,
      "uvIndex": 2,
      "precipitation": 90,
      "icon": "rainy"
    },
    {
      "day": "Thursday",
      "date": "Dec 18",
      "highTemp": 24,
      "lowTemp": 16,
      "condition": "Cloudy",
      "humidity": 70,
      "uvIndex": 4,
      "precipitation": 30,
      "icon": "cloudy"
    },
    {
      "day": "Friday",
      "date": "Dec 19",
      "highTemp": 27,
      "lowTemp": 19,
      "condition": "Sunny",
      "humidity": 55,
      "uvIndex": 7,
      "precipitation": 5,
      "icon": "sunny"
    },
    {
      "day": "Saturday",
      "date": "Dec 20",
      "highTemp": 30,
      "lowTemp": 21,
      "condition": "Sunny",
      "humidity": 50,
      "uvIndex": 8,
      "precipitation": 0,
      "icon": "sunny"
    },
    {
      "day": "Sunday",
      "date": "Dec 21",
      "highTemp": 31,
      "lowTemp": 23,
      "condition": "Partly Cloudy",
      "humidity": 60,
      "uvIndex": 6,
      "precipitation": 15,
      "icon": "partly_cloudy_day"
    }
  ];

  final List<Map<String, dynamic>> _farmingAlerts = [
    {
      "id": 1,
      "type": "frost",
      "title": "Frost Alert",
      "message":
          "Temperature may drop below 2°C tonight. Protect sensitive crops.",
      "severity": "high",
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
      "action":
          "Cover crops with protective sheets or move potted plants indoors."
    },
    {
      "id": 2,
      "type": "rain",
      "title": "Heavy Rain Warning",
      "message":
          "Expected 50mm rainfall in next 48 hours. Check drainage systems.",
      "severity": "medium",
      "timestamp": DateTime.now().subtract(Duration(hours: 3)),
      "action":
          "Ensure proper field drainage and postpone fertilizer application."
    },
    {
      "id": 3,
      "type": "planting",
      "title": "Optimal Planting Window",
      "message":
          "Weather conditions favorable for winter wheat planting next week.",
      "severity": "low",
      "timestamp": DateTime.now().subtract(Duration(hours: 6)),
      "action": "Prepare seeds and equipment for planting between Dec 22-25."
    }
  ];

  Future<void> _refreshWeatherData() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _currentWeather["lastUpdated"] = DateTime.now();
    });
  }

  void _showWeatherSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weather Settings',
                    style: AppTheme.lightTheme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: 3.h),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'thermostat',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Temperature Unit'),
                    subtitle: Text('Celsius'),
                    trailing: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Location Services'),
                    subtitle: Text('Enabled'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'notifications',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Weather Notifications'),
                    subtitle: Text('Enabled'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Farm Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'my_location',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Use Current Location'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Search Location'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Weather Dashboard'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showLocationPicker,
            icon: CustomIconWidget(
              iconName: 'location_on',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _showWeatherSettings,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWeatherData,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weather Card
              CurrentWeatherCardWidget(
                weatherData: _currentWeather,
                isRefreshing: _isRefreshing,
              ),

              SizedBox(height: 3.h),

              // Hourly Forecast Section
              Text(
                'Hourly Forecast',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              HourlyForecastWidget(hourlyData: _hourlyForecast),

              SizedBox(height: 3.h),

              // Daily Forecast Section
              Text(
                '7-Day Forecast',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              DailyForecastWidget(dailyData: _dailyForecast),

              SizedBox(height: 3.h),

              // Farming Alerts Section
              Text(
                'Farming Alerts',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              FarmingAlertsWidget(alertsData: _farmingAlerts),

              SizedBox(height: 10.h), // Bottom padding for navigation
            ],
          ),
        ),
      ),
    );
  }
}
