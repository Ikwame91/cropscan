// main_screen.dart

import 'package:cropscan_pro/core/app_export.dart'
    show AppTheme, CustomIconWidget;
import 'package:flutter/material.dart';

import 'package:cropscan_pro/presentation/dashboard_home/dashboard_home.dart'; // This is your refactored Home screen
import 'package:cropscan_pro/presentation/crop_scanner_camera/crop_scanner_camera.dart';
import 'package:cropscan_pro/presentation/weather_dashboard/weather_dashboard.dart';
import 'package:cropscan_pro/presentation/alert_screen/cropscreen.dart';
import 'package:cropscan_pro/presentation/user_profile_settings/user_profile_settings.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

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

  @override
  void initState() {
    super.initState();
    // Initialize the list of screens
    _screens = [
      const DashboardHome(), // This is your refactored Home screen content
      const CropScannerCamera(),
      const WeatherDashboard(),
      const CropScreen(),
      const UserProfileSettings(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed, // Use fixed for consistent styling
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
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
            icon: CustomIconWidget(
              iconName: 'local_florist',
              color: _currentIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            label: 'My Crops',
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
