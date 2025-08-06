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
  static const Duration _snackBarDuration = Duration(seconds: 2);
  static const Duration _errorSnackBarDuration = Duration(seconds: 4);
  static const int _scanTabIndex = 1;

  // State
  int _currentIndex = 0;
  final GlobalKey<CropScannerCameraState> _cameraScreenKey = GlobalKey();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
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

  void goToTab(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }

  void _onTabTapped(int index) async {
    if (index == _scanTabIndex) {
      await _handleScanTabTap();
    } else {
      _navigateToTab(index);
    }
  }

  Future<void> _handleScanTabTap() async {
    final tfliteService = context.read<TfLiteModelServices>();

    switch (tfliteService.status) {
      case ModelPredictionStatus.initial:
        await _loadModelAndNavigate(tfliteService);
        break;
      case ModelPredictionStatus.loading:
        _showLoadingMessage();
        break;
      case ModelPredictionStatus.ready:
        _navigateToScanTab();
        break;
      case ModelPredictionStatus.error:
        _showErrorMessage();
        break;
      case ModelPredictionStatus.predicting:
        _showBusyMessage();
        break;
    }
  }

  Future<void> _loadModelAndNavigate(TfLiteModelServices service) async {
    _showSnackBar("Loading AI model for scanning...", _snackBarDuration);

    try {
      await service.loadModelAndLabels();
      if (mounted && service.status == ModelPredictionStatus.ready) {
        _navigateToScanTab();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          "Failed to load AI model. Please try again.",
          _errorSnackBarDuration,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _navigateToScanTab() {
    _navigateToTab(_scanTabIndex);
    _cameraScreenKey.currentState?.initializeCameraOnDemand();
  }

  void _navigateToTab(int index) {
    if (_currentIndex == _scanTabIndex && index != _scanTabIndex) {
      _cameraScreenKey.currentState?.pauseCameraPreview();
    }

    // If we're entering the camera tab, resume the camera
    if (index == _scanTabIndex && _currentIndex != _scanTabIndex) {
      _cameraScreenKey.currentState?.resumeCameraPreview();
    }

    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }

  void _showLoadingMessage() {
    _showSnackBar(
        "AI model is still loading, please wait...", _snackBarDuration);
  }

  void _showErrorMessage() {
    _showSnackBar(
      "AI model failed to load. Please restart the app or try again.",
      _errorSnackBarDuration,
      backgroundColor: Colors.red,
    );
  }

  void _showBusyMessage() {
    _showSnackBar(
      "Model is currently busy, please wait for current scan to finish.",
      _snackBarDuration,
    );
  }

  void _showSnackBar(String message, Duration duration,
      {Color? backgroundColor}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TfLiteModelServices>(
      builder: (context, tfliteService, child) {
        final scanTabConfig = _getScanTabConfig(tfliteService.status);

        return Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(scanTabConfig),
        );
      },
    );
  }

  ScanTabConfig _getScanTabConfig(ModelPredictionStatus status) {
    switch (status) {
      case ModelPredictionStatus.loading:
        // Keep camera icon but change color to show loading
        return ScanTabConfig('camera_alt', 'Loading...', Colors.orange);
      case ModelPredictionStatus.error:
        return ScanTabConfig(
            'camera_alt', 'Scan', Colors.red); // Keep camera, just red
      case ModelPredictionStatus.predicting:
        return ScanTabConfig(
            'camera_alt', 'Scanning...', Colors.blue); // Keep camera, just blue
      case ModelPredictionStatus.initial:
      case ModelPredictionStatus.ready:
        return ScanTabConfig(
          'camera_alt',
          'Scan',
          _currentIndex == _scanTabIndex
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        );
    }
  }

  BottomNavigationBar _buildBottomNavigationBar(ScanTabConfig scanConfig) {
    return BottomNavigationBar(
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
      items: _buildNavigationItems(scanConfig),
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems(
      ScanTabConfig scanConfig) {
    return [
      _buildNavItem('home', 'Home', 0),
      BottomNavigationBarItem(
        icon: CustomIconWidget(
          iconName: scanConfig.iconName,
          color: scanConfig.color,
          size: 24,
        ),
        label: scanConfig.label,
      ),
      _buildNavItem('wb_sunny', 'Weather', 2),
      _buildNavItem('local_florist', 'My Crops', 3),
      _buildNavItem('person', 'Profile', 4),
    ];
  }

  BottomNavigationBarItem _buildNavItem(
      String iconName, String label, int index) {
    return BottomNavigationBarItem(
      icon: CustomIconWidget(
        iconName: iconName,
        color: _currentIndex == index
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      label: label,
    );
  }
}

class ScanTabConfig {
  final String iconName;
  final String label;
  final Color color;

  ScanTabConfig(this.iconName, this.label, this.color);
}
