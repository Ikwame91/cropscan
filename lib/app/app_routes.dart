import 'package:cropscan_pro/features/diagnosis/diagnosis_args.dart';
import 'package:cropscan_pro/data/models/crop_info.dart';
import 'package:cropscan_pro/features/history/crops_screen.dart';
import 'package:cropscan_pro/features/diagnosis/crop_detection_results.dart';
import 'package:cropscan_pro/app/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:cropscan_pro/features/home/dashboard_home.dart';
import 'package:cropscan_pro/features/scan/crop_scanner_camera.dart';
import 'package:cropscan_pro/features/profile/user_profile_settings.dart';
import 'package:cropscan_pro/features/guide/crop_guide_screen.dart';
import 'package:cropscan_pro/features/history/detection_history.dart';

class AppRoutes {
  static const String initial = '/';
  static const String mainscreen = '/main-screen';
  static const String dashboardHome = '/dashboard-home';
  static const String cropScannerCamera = '/crop-scanner-camera';
  static const String cropDetectionResults = '/crop-detection-results';
  static const String weatherDashboard = '/weather-dashboard';
  static const String detectionHistory = '/detection-history';
  static const String cropcareDashboard = '/cropcare-dashboard';
  static const String userProfileSettings = '/user-profile-settings';
  static const String cropscreen = '/cropscreen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => MainScreen(),
    dashboardHome: (context) => const DashboardHome(),
    cropScannerCamera: (context) => const CropScannerCamera(),
    cropcareDashboard: (context) => const CropCareDashboard(),
    detectionHistory: (context) => const DetectionHistory(),
    cropscreen: (context) => const CropScreen(),
    userProfileSettings: (context) => const UserProfileSettings(),
    cropDetectionResults: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;

      if (args is CropDetectionResultsArgs) {
        return CropDetectionResults(
          imagePath: args.imagePath,
          detectedCrop: args.detectedCrop,
          confidence: args.confidence,
          cropInfo: args.cropInfo,
          isFromHistory: args.isFromHistory,
        );
      }

      if (args is Map) {
        try {
          return CropDetectionResults(
            imagePath: args['imagePath'] as String,
            detectedCrop: args['detectedCrop'] as String,
            confidence: (args['confidence'] as num).toDouble(),
            cropInfo: args['cropInfo'] as CropInfo,
          );
        } catch (_) {}
      }

      debugPrint(
          "Error: CropDetectionResults received null or invalid arguments. Got: ${args.runtimeType}");
      return Scaffold(
        body: Center(
          child: Text(
            'Error: Invalid arguments for Crop Detection Results screen.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
  };
}
