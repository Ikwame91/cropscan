import 'package:cropscan_pro/data/models/crop_info.dart';
import 'package:cropscan_pro/data/models/disease_info.dart';

class CropDetectionResultsArgs {
  final String imagePath;
  final String detectedCrop;
  final double confidence;
  final CropInfo cropInfo;
  final bool isFromHistory;
  final EnhancedCropInfo? enhancedCropInfo;

  CropDetectionResultsArgs({
    required this.imagePath,
    required this.detectedCrop,
    required this.confidence,
    required this.cropInfo,
    this.enhancedCropInfo,
    this.isFromHistory = false,
  });
}
