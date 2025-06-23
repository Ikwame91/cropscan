import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/farming_alert_card_widget.dart';
import './widgets/recent_detection_card_widget.dart';
import './widgets/scan_crop_card_widget.dart';
import './widgets/weather_widget.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isRefreshing = false;

  // Mock data for recent detections
  final List<Map<String, dynamic>> recentDetections = [
    {
      "id": 1,
      "cropName": "Bell Pepper",
      "confidence": 94.5,
      "imageUrl":
          "https://images.pexels.com/photos/594137/pexels-photo-594137.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "detectedAt": DateTime.now().subtract(Duration(hours: 2)),
      "status": "Healthy"
    },
    {
      "id": 2,
      "cropName": "Tomato",
      "confidence": 89.2,
      "imageUrl":
          "https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "detectedAt": DateTime.now().subtract(Duration(hours: 5)),
      "status": "Disease Detected"
    },
    {
      "id": 3,
      "cropName": "Maize",
      "confidence": 96.8,
      "imageUrl":
          "https://images.pexels.com/photos/547263/pexels-photo-547263.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "detectedAt": DateTime.now().subtract(Duration(days: 1)),
      "status": "Healthy"
    }
  ];

  // Mock data for farming alerts
  final List<Map<String, dynamic>> farmingAlerts = [
    {
      "id": 1,
      "title": "Irrigation Reminder",
      "message": "Time to water your tomato plants in Field A",
      "priority": "high",
      "type": "irrigation",
      "timestamp": DateTime.now().subtract(Duration(minutes: 30)),
      "isRead": false
    },
    {
      "id": 2,
      "title": "Weather Alert",
      "message": "Heavy rain expected tomorrow. Protect your crops",
      "priority": "critical",
      "type": "weather",
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
      "isRead": false
    },
    {
      "id": 3,
      "title": "Fertilizer Application",
      "message": "Apply nitrogen fertilizer to maize field this week",
      "priority": "medium",
      "type": "fertilizer",
      "timestamp": DateTime.now().subtract(Duration(hours: 3)),
      "isRead": true
    },
    {
      "id": 4,
      "title": "Pest Detection",
      "message": "Aphids detected in bell pepper section. Take action",
      "priority": "critical",
      "type": "pest",
      "timestamp": DateTime.now().subtract(Duration(hours: 6)),
      "isRead": false
    }
  ];

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/crop-scanner-camera');
        break;
      case 2:
        Navigator.pushNamed(context, '/weather-dashboard');
        break;
      case 3:
        // Show alerts section
        break;
      case 4:
        Navigator.pushNamed(context, '/user-profile-settings');
        break;
    }
  }

  void _onDetectionCardTap(Map<String, dynamic> detection) {
    Navigator.pushNamed(context, '/crop-detection-results',
        arguments: detection);
  }

  void _onAlertLongPress(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Mark as Read'),
              onTap: () {
                Navigator.pop(context);
                // Handle mark as read
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'snooze',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
              title: Text('Snooze'),
              onTap: () {
                Navigator.pop(context);
                // Handle snooze
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 24,
              ),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Handle share
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                title: Text(
                  'CropScan Pro',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/detection-history'),
                    icon: CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.all(4.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Weather Widget

                    SizedBox(height: 3.h),

                    // Scan Crop Card
                    ScanCropCardWidget(
                      onTap: () =>
                          Navigator.pushNamed(context, '/crop-scanner-camera'),
                    ),
                    SizedBox(height: 3.h),

                    // Recent Detections Section
                    if (recentDetections.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Detections',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/detection-history'),
                            child: Text('View All'),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        height: 30.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recentDetections.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 3.w),
                          itemBuilder: (context, index) {
                            final detection = recentDetections[index];
                            return RecentDetectionCardWidget(
                              detection: detection,
                              onTap: () => _onDetectionCardTap(detection),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ] else ...[
                      // Empty state for detections
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: AppTheme.lightTheme.dividerColor,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: 'camera_alt',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Scan Your First Crop',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Use AI-powered detection to identify your crops and get farming insights',
                              textAlign: TextAlign.center,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ],

                    // Farming Alerts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Farming Alerts',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            '${farmingAlerts.where((alert) => !(alert["isRead"] as bool)).length}',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Alerts List
                    ...farmingAlerts.take(3).map((alert) => Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: FarmingAlertCardWidget(
                            alert: alert,
                            onLongPress: () => _onAlertLongPress(alert),
                          ),
                        )),

                    if (farmingAlerts.length > 3)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Show all alerts
                          },
                          child:
                              Text('View All Alerts (${farmingAlerts.length})'),
                        ),
                      ),

                    SizedBox(height: 10.h), // Bottom padding for FAB
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/crop-scanner-camera'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        icon: CustomIconWidget(
          iconName: 'camera_alt',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          'Scan Crop',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _currentIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: _currentIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'wb_sunny',
              color: _currentIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: _currentIndex == 3
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                if (farmingAlerts
                    .where((alert) => !(alert["isRead"] as bool))
                    .isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 4
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
