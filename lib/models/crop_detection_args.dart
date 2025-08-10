import '../presentation/crop_scanner_camera/widgets/crop_info.dart';

class CropDetectionResultsArgs {
  final String imagePath;
  final String detectedCrop;
  final double confidence;
  final CropInfo? cropInfo;

  CropDetectionResultsArgs({
    required this.imagePath,
    required this.detectedCrop,
    required this.confidence,
    required this.cropInfo,
  });

  @override
  String toString() {
    return 'CropDetectionResultsArgs(imagePath: $imagePath, detectedCrop: $detectedCrop, confidence: $confidence, cropInfo: $cropInfo)';
  }
}
