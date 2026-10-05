import 'package:cropscan_pro/app/navigation_provider.dart';
import 'package:cropscan_pro/core/ml/crop_classifier.dart';
import 'package:cropscan_pro/features/follow_ups/care_plan_screen.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_provider.dart';
import 'package:cropscan_pro/features/guide/crop_guide_screen.dart';
import 'package:cropscan_pro/features/home/dashboard_home.dart';
import 'package:cropscan_pro/features/profile/user_profile_settings.dart';
import 'package:cropscan_pro/features/scan/crop_scanner_camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Bottom-navigation shell. Tabs live in an [IndexedStack] so they keep
/// their state (and the camera stays warm) when switching.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<CropScannerCameraState> _cameraScreenKey = GlobalKey();
  late final List<Widget> _screens = [
    const DashboardHome(),
    CropScannerCamera(key: _cameraScreenKey),
    const CropCareDashboard(),
    const CarePlanScreen(),
    const UserProfileSettings(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().setCameraKey(_cameraScreenKey);
    });
  }

  Future<void> _onTabTapped(int index) async {
    final navigation = context.read<NavigationProvider>();
    final tab = AppTab.values[index];
    if (tab != AppTab.scan) {
      navigation.navigateToTab(tab);
      return;
    }

    final status = context.read<CropClassifier>().status;
    if (status == ModelPredictionStatus.loading) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Loading crop detection model...'),
        duration: Duration(seconds: 2),
      ));
    }
    try {
      await navigation.navigateToCamera();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to initialize camera: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;
    final dueCount =
        context.select<FollowUpProvider, int>((p) => p.dueNow.length);
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Scan'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            activeIcon: Icon(Icons.eco),
            label: 'Crop Guide',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: dueCount > 0,
              label: Text('$dueCount'),
              child: const Icon(Icons.event_note_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: dueCount > 0,
              label: Text('$dueCount'),
              child: const Icon(Icons.event_note),
            ),
            label: 'Care plan',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
