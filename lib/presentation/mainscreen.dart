// main_screen.dart

import 'package:cropscan_pro/core/services/tf_lite_model_services.dart';
import 'package:cropscan_pro/providers/naviagtion_provider.dart';
import 'package:flutter/material.dart';
import 'package:cropscan_pro/presentation/dashboard_home/dashboard_home.dart';
import 'package:cropscan_pro/presentation/crop_scanner_camera/crop_scanner_camera.dart';
import 'package:cropscan_pro/presentation/weather_dashboard/weather_dashboard.dart';
import 'package:cropscan_pro/presentation/alert_screen/cropscreen.dart';
import 'package:cropscan_pro/presentation/user_profile_settings/user_profile_settings.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  static const Duration _snackBarDuration = Duration(seconds: 2);
  static const Duration _errorSnackBarDuration = Duration(seconds: 4);
  static const int _scanTabIndex = 1;

  final GlobalKey<CropScannerCameraState> _cameraScreenKey = GlobalKey();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreens();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().setCameraKey(_cameraScreenKey);
    });
  }

  @override
  void dispose() {
    // FIXED: Remove explicit camera disposal - CropScannerCamera handles its own lifecycle
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initializeScreens() {
    _screens = [
      const DashboardHome(),
      CropScannerCamera(key: _cameraScreenKey),
      const WeatherDashboard(),
      const CropScreen(),
      const UserProfileSettings(),
    ];
  }

  void _onTabTapped(int index) async {
    final navigationProvider = context.read<NavigationProvider>();

    // FIXED: Simple navigation without camera conflicts
    if (index == _scanTabIndex) {
      await _handleScanTabTap(navigationProvider);
    } else {
      navigationProvider.navigateToTab(index); // No camera interference
    }
  }

  Future<void> _handleScanTabTap(NavigationProvider navigationProvider) async {
    final tfliteService = context.read<TfLiteModelServices>();

    switch (tfliteService.status) {
      case ModelPredictionStatus.initial:
      case ModelPredictionStatus.error:
        // Navigate to camera tab and let it handle model loading
        navigationProvider.navigateToTab(_scanTabIndex);

        // FIXED: Let camera handle its own initialization
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await _cameraScreenKey.currentState?.initializeCameraOnDemand();
          } catch (e) {
            _showErrorSnackBar("Failed to initialize camera: $e");
          }
        });
        break;

      case ModelPredictionStatus.loading:
        // Model is loading, just navigate and show loading state
        navigationProvider.navigateToTab(_scanTabIndex);
        _showInfoSnackBar("Loading crop detection model...");
        break;

      case ModelPredictionStatus.ready:
      case ModelPredictionStatus.predicting:
        // Everything ready, navigate normally
        navigationProvider.navigateToTab(_scanTabIndex);
        break;
    }
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: _snackBarDuration,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: _errorSnackBarDuration,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud),
                label: 'Weather',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grass),
                label: 'Crops',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
