import 'package:cropscan_pro/presentation/alert_screen/alert_screen.dart';
import 'package:cropscan_pro/presentation/mainscreen.dart';
import 'package:flutter/material.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/crop_scanner_camera/crop_scanner_camera.dart';
import '../presentation/user_profile_settings/user_profile_settings.dart';
import '../presentation/crop_detection_results/crop_detection_results.dart';
import '../presentation/weather_dashboard/weather_dashboard.dart';
import '../presentation/detection_history/detection_history.dart';

class AppRoutes {
  static const String initial = '/';
  static const String mainscreen = '/main-screen';
  static const String dashboardHome = '/dashboard-home';
  static const String cropScannerCamera = '/crop-scanner-camera';
  static const String cropDetectionResults = '/crop-detection-results';
  static const String weatherDashboard = '/weather-dashboard';
  static const String detectionHistory = '/detection-history';
  static const String userProfileSettings = '/user-profile-settings';
  static const String alertScreen = '/alert-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const MainScreen(),
    dashboardHome: (context) => const DashboardHome(),
    cropScannerCamera: (context) => const CropScannerCamera(),
    cropDetectionResults: (context) => const CropDetectionResults(),
    weatherDashboard: (context) => const WeatherDashboard(),
    detectionHistory: (context) => const DetectionHistory(),
    alertScreen: (context) => const AlertScreen(),
    userProfileSettings: (context) => const UserProfileSettings(),
  };
}
