import 'package:flutter/widgets.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _shouldInitializeCamera = false;

  int get currentIndex => _currentIndex;
  bool get shouldInitializeCamera => _shouldInitializeCamera;

  void navigateToTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void navigateToCamera() {
    _shouldInitializeCamera = true;
    _currentIndex = 1;
    notifyListeners();
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
