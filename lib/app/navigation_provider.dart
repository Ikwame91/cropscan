import 'package:cropscan_pro/features/scan/crop_scanner_camera.dart';
import 'package:flutter/widgets.dart';

/// Bottom-navigation tabs, in display order.
enum AppTab { home, scan, guide, carePlan, profile }

class NavigationProvider extends ChangeNotifier {
  AppTab _currentTab = AppTab.home;
  GlobalKey<CropScannerCameraState>? _cameraKey;

  AppTab get currentTab => _currentTab;
  int get currentIndex => _currentTab.index;

  void setCameraKey(GlobalKey<CropScannerCameraState> key) {
    _cameraKey = key;
  }

  void navigateToTab(AppTab tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    notifyListeners();
  }

  /// Switches to the Scan tab and starts the camera if needed.
  Future<void> navigateToCamera() async {
    navigateToTab(AppTab.scan);
    try {
      await _cameraKey?.currentState?.initializeCameraOnDemand();
    } catch (e) {
      debugPrint('NavigationProvider: error initializing camera: $e');
    }
  }

  /// Pops any pushed routes, then shows [tab]. Use from screens pushed on
  /// top of the main shell (results, history, ...).
  void returnToTab(BuildContext context, AppTab tab) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (tab == AppTab.scan) {
      navigateToCamera();
    } else {
      navigateToTab(tab);
    }
  }
}
