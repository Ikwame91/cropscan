// main_screen.dart

import 'package:cropscan_pro/core/app_export.dart'
    show AppTheme, CustomIconWidget;
import 'package:cropscan_pro/core/services/tf_lite_model_services.dart';
import 'package:cropscan_pro/providers/naviagtion_provider.dart';
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
  }

  @override
  void dispose() {
    _cameraScreenKey.currentState?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final navigationProvider = context.read<NavigationProvider>();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _cameraScreenKey.currentState?.pauseCameraPreview();
        break;
      case AppLifecycleState.resumed:
        if (navigationProvider.currentIndex == _scanTabIndex) {
          _cameraScreenKey.currentState?.resumeCameraPreview();
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _cameraScreenKey.currentState?.pauseCameraPreview();
        break;
    }
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

    if (navigationProvider.currentIndex == _scanTabIndex &&
        index != _scanTabIndex) {
      debugPrint("🔄 Leaving camera tab - pausing camera");
      _cameraScreenKey.currentState?.pauseCameraPreview();
    }
    if (index == _scanTabIndex) {
      await _handleScanTabTap(navigationProvider);
    } else {
      navigationProvider.navigateToTab(index);
    }
  }

  Future<void> _handleScanTabTap(NavigationProvider navigationProvider) async {
    final tfliteService = context.read<TfLiteModelServices>();

    switch (tfliteService.status) {
      case ModelPredictionStatus.initial:
        await _loadModelAndNavigate(tfliteService, navigationProvider);
        break;
      case ModelPredictionStatus.loading:
        _showLoadingMessage();
        break;
      case ModelPredictionStatus.ready:
        _navigateToScanTab(navigationProvider);
        break;
      case ModelPredictionStatus.error:
        _showErrorMessage();
        break;
      case ModelPredictionStatus.predicting:
        _showBusyMessage();
        break;
    }
  }

  Future<void> _loadModelAndNavigate(TfLiteModelServices service,
      NavigationProvider navigationProvider) async {
    _showSnackBar("Loading AI model for scanning...", _snackBarDuration);

    try {
      await service.loadModelAndLabels();
      if (mounted && service.status == ModelPredictionStatus.ready) {
        _navigateToScanTab(navigationProvider);
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

  void _navigateToScanTab(NavigationProvider navigationProvider) {
    navigationProvider.navigateToCamera();
    _cameraScreenKey.currentState?.initializeCameraOnDemand();
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
    return Consumer2<TfLiteModelServices, NavigationProvider>(
      builder: (context, tfliteService, navigationProvider, child) {
        final scanTabConfig = _getScanTabConfig(tfliteService.status);

        // Handle camera initialization when flag is set
        if (navigationProvider.shouldInitializeCamera) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _cameraScreenKey.currentState?.initializeCameraOnDemand();
            navigationProvider.resetCameraInitFlag();
          });
        }

        return Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          body: SafeArea(
            child: IndexedStack(
              index: navigationProvider.currentIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(
            scanTabConfig,
            navigationProvider.currentIndex,
          ),
        );
      },
    );
  }

  ScanTabConfig _getScanTabConfig(ModelPredictionStatus status) {
    switch (status) {
      case ModelPredictionStatus.loading:
        return ScanTabConfig('camera_alt', 'Loading...', Colors.orange);
      case ModelPredictionStatus.error:
        return ScanTabConfig('camera_alt', 'Scan', Colors.red);
      case ModelPredictionStatus.predicting:
        return ScanTabConfig('camera_alt', 'Scanning...', Colors.blue);
      case ModelPredictionStatus.initial:
      case ModelPredictionStatus.ready:
        return ScanTabConfig(
          'camera_alt',
          'Scan',
          context.read<NavigationProvider>().currentIndex == _scanTabIndex
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        );
    }
  }

  BottomNavigationBar _buildBottomNavigationBar(
      ScanTabConfig scanConfig, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
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
      items: _buildNavigationItems(scanConfig, currentIndex),
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems(
      ScanTabConfig scanConfig, int currentIndex) {
    return [
      _buildNavItem('home', 'Home', 0, currentIndex),
      BottomNavigationBarItem(
        icon: CustomIconWidget(
          iconName: scanConfig.iconName,
          color: scanConfig.color,
          size: 24,
        ),
        label: scanConfig.label,
      ),
      _buildNavItem('wb_sunny', 'Weather', 2, currentIndex),
      _buildNavItem('local_florist', 'My Crops', 3, currentIndex),
      _buildNavItem('person', 'Profile', 4, currentIndex),
    ];
  }

  BottomNavigationBarItem _buildNavItem(
      String iconName, String label, int index, int currentIndex) {
    return BottomNavigationBarItem(
      icon: CustomIconWidget(
        iconName: iconName,
        color: currentIndex == index
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
