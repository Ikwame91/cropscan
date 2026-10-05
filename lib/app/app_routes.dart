import 'package:cropscan_pro/app/main_shell.dart';
import 'package:cropscan_pro/features/diagnosis/crop_detection_results.dart';
import 'package:cropscan_pro/features/diagnosis/diagnosis_args.dart';
import 'package:cropscan_pro/features/guide/disease_detail_screen.dart';
import 'package:cropscan_pro/features/history/detection_history.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String initial = '/';
  static const String cropDetectionResults = '/crop-detection-results';
  static const String detectionHistory = '/detection-history';

  /// Argument: the model label (String) of the condition to show.
  static const String diseaseDetail = '/disease-detail';

  /// The tabs (home, scan, guide, ...) live inside [MainScreen] and are
  /// switched with NavigationProvider, not pushed as routes.
  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const MainScreen(),
    detectionHistory: (context) => const DetectionHistory(),
    diseaseDetail: (context) => DiseaseDetailScreen(
          rawLabel: ModalRoute.of(context)!.settings.arguments as String,
        ),
    cropDetectionResults: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is DiagnosisArgs) {
        return CropDetectionResults(
          detectionId: args.detectionId,
          justScanned: args.justScanned,
        );
      }
      return const Scaffold(
        body: Center(child: Text('Invalid arguments for results screen.')),
      );
    },
  };
}
