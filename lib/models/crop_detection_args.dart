import 'package:cropscan_pro/models/crop_info.dart';

class CropDetectionResultsArgs {
  final String imagePath;
  final String detectedCrop;
  final double confidence;
  final CropInfo cropInfo;

  CropDetectionResultsArgs({
    required this.imagePath,
    required this.detectedCrop,
    required this.confidence,
    required this.cropInfo,
  });
}
