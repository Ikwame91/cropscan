import 'package:cropscan_pro/core/ml/crop_classifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('keeps pixel values in the 0-255 range the model expects', () {
    // The model folds Rescaling(1/255) into its first convolution, so
    // normalising here would break every prediction.
    final image = img.Image(width: 10, height: 10)
      ..clear(img.ColorRgb8(200, 100, 50));
    final input = CropClassifier.preprocess(image);

    expect(input.length,
        CropClassifier.inputSize * CropClassifier.inputSize * 3);
    expect(input.sublist(0, 3), [200, 100, 50]);
  });

  test('flattens transparency onto white', () {
    final image = img.Image(width: 4, height: 4, numChannels: 4)
      ..clear(img.ColorRgba8(0, 0, 0, 0));
    expect(CropClassifier.preprocess(image).sublist(0, 3), [255, 255, 255]);
  });

  test('labels file parsing ignores blank lines', () {
    expect(CropClassifier.parseLabels('a\n\n b \n'), ['a', 'b']);
  });
}
