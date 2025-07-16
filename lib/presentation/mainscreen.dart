// main_screen.dart

import 'package:cropscan_pro/core/app_export.dart'
    show AppTheme, CustomIconWidget;
import 'package:flutter/material.dart';
import 'package:cropscan_pro/presentation/dashboard_home/dashboard_home.dart';
import 'package:cropscan_pro/presentation/crop_scanner_camera/crop_scanner_camera.dart';
import 'package:cropscan_pro/presentation/weather_dashboard/weather_dashboard.dart';
import 'package:cropscan_pro/presentation/alert_screen/cropscreen.dart';
import 'package:cropscan_pro/presentation/user_profile_settings/user_profile_settings.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // Use a GlobalKey to access the state of CropScannerCamera
  final GlobalKey<CropScannerCameraState> _cameraScreenKey = GlobalKey();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardHome(),
      // Pass the key to the CropScannerCamera
      CropScannerCamera(key: _cameraScreenKey),
      const WeatherDashboard(),
      const CropScreen(),
      const UserProfileSettings(),
    ];
  }

  void goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // If the 'Scan' tab (index 1) is selected, initialize the camera
    if (index == 1) {
      // Using the GlobalKey to call a method on the state of CropScannerCamera
      _cameraScreenKey.currentState?.initializeCameraOnDemand();
    } else {
      // Optionally, if you want to stop/dispose camera when leaving the tab,
      // you could add a method like `_cameraScreenKey.currentState?.disposeCamera()`
      // to `_CropScannerCameraState` and call it here.
      // For now, `didChangeAppLifecycleState` in CameraScreen handles backgrounding.
    }
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
        type: BottomNavigationBarType.fixed,
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
