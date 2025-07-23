// main_screen.dart

import 'package:cropscan_pro/core/app_export.dart'
    show AppTheme, CustomIconWidget;
import 'package:cropscan_pro/core/services/tf_lite_model_services.dart';
import 'package:flutter/material.dart';
import 'package:cropscan_pro/presentation/dashboard_home/dashboard_home.dart';
import 'package:cropscan_pro/presentation/crop_scanner_camera/crop_scanner_camera.dart';
import 'package:cropscan_pro/presentation/weather_dashboard/weather_dashboard.dart';
import 'package:cropscan_pro/presentation/alert_screen/cropscreen.dart';
import 'package:cropscan_pro/presentation/user_profile_settings/user_profile_settings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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

  void _onTabTapped(int index) async {
    // Access the TFLiteModelService
    final tfliteService =
        Provider.of<TfLiteModelServices>(context, listen: false);

    if (index == 1) {
      switch (tfliteService.status) {
        case ModelPredictionStatus.initial:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Loading AI model for scanning ..."),
              duration: Duration(seconds: 2),
            ),
          );
          try {
            await tfliteService.loadModelAndLabels();
            if (mounted &&
                tfliteService.status == ModelPredictionStatus.ready) {
              setState(() {
                _currentIndex = index;
              });
              _cameraScreenKey.currentState?.initializeCameraOnDemand();
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Failed to load AI model: ${e.toString()}"),
              duration: Duration(seconds: 2),
            ));
          }
          break;
        case ModelPredictionStatus.loading:
          // Model is already loading, just inform the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI model is still loading, please wait...'),
              duration: Duration(seconds: 2),
            ),
          );
          // Do NOT navigate
          break;
        case ModelPredictionStatus.ready:
          // Model is ready, proceed normally
          setState(() {
            _currentIndex = index;
          });
          _cameraScreenKey.currentState?.initializeCameraOnDemand();
          break;
        case ModelPredictionStatus.error:
          // Model is in an error state, inform the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'AI model failed to load. Please restart the app or try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
          // Do NOT navigate
          break;
        case ModelPredictionStatus.predicting:
          // Model is busy with a prediction, inform the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Model is currently busy, please wait for current scan to finish.'),
              duration: Duration(seconds: 2),
            ),
          );
          // Do NOT navigate
          break;
      }
    } else {
      // For other tabs, simply navigate
      setState(() {
        _currentIndex = index;
      });
      // Optionally, if you want to stop/dispose camera when leaving the tab,
      // you could add a method like `_cameraScreenKey.currentState?.disposeCamera()`
      // to `_CropScannerCameraState` and call it here.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TfLiteModelServices>(
      builder: (context, tfliteService, child) {
        String scanIconName = 'camera_alt';
        String scanLabel = 'Scan';
        Color scanItemColor = _currentIndex == 1
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant;

        switch (tfliteService.status) {
          case ModelPredictionStatus.loading:
            scanIconName = 'downloading';
            scanLabel = 'Loading...';
            scanItemColor = Colors.orange;
            break;
          case ModelPredictionStatus.error:
            scanIconName = 'error_outline';
            scanLabel = 'Error';
            scanItemColor = Colors.red;
            break;
          case ModelPredictionStatus.initial:
            // Default 'camera_alt' and 'Scan' will apply
            break;
          case ModelPredictionStatus.predicting:
            scanIconName = 'autorenew'; // Icon name for predicting
            scanLabel = 'Predicting...';
            scanItemColor = Colors.blue;
            break;
          case ModelPredictionStatus.ready:
            // All good, default 'camera_alt' and 'Scan' will apply
            break;
        }

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
            unselectedItemColor:
                AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
                  iconName: scanIconName,
                  color: scanItemColor,
                  size: 24,
                ),
                label: scanLabel,
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
      },
    );
  }
}
