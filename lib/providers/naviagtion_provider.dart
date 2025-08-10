import 'package:cropscan_pro/presentation/crop_scanner_camera/crop_scanner_camera.dart';
import 'package:flutter/widgets.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _shouldInitializeCamera = false;
  GlobalKey<CropScannerCameraState>? _cameraKey;

  int get currentIndex => _currentIndex;
  bool get shouldInitializeCamera => _shouldInitializeCamera;

  void setCameraKey(GlobalKey<CropScannerCameraState> key) {
    _cameraKey = key;
  }

  void navigateToTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<void> navigateToCamera() async {
    _currentIndex = 1;
    notifyListeners();

    if (_cameraKey?.currentState != null) {
      try {
        await _cameraKey!.currentState!.initializeCameraOnDemand();
      } catch (e) {
        debugPrint("Error initializing camera: $e");
      }
    }
  }

  void resetCameraInitFlag() {
    _shouldInitializeCamera = false;
    notifyListeners();
  }

  void resetNavigation() {
    _currentIndex = 0;
    _shouldInitializeCamera = false;
    notifyListeners();
  }
}
