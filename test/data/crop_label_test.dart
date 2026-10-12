import 'package:cropscan_pro/data/knowledge/crop_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses every label shape the model emits', () {
    final cases = {
      'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot':
          ('Maize', 'Cercospora Leaf Spot Gray Leaf Spot', false),
      'Corn_(maize)___Common_rust_': ('Maize', 'Common Rust', false),
      'Corn_(maize)___healthy': ('Maize', 'Healthy', true),
      'Pepper__bell___Bacterial_spot': ('Bell Pepper', 'Bacterial Spot', false),
      'Tomato_Early_blight': ('Tomato', 'Early Blight', false),
      'Tomato__Target_Spot': ('Tomato', 'Target Spot', false),
      'Tomato__Tomato_YellowLeaf__Curl_Virus':
          ('Tomato', 'Yellowleaf Curl Virus', false),
      'Tomato_healthy': ('Tomato', 'Healthy', true),
    };
    cases.forEach((raw, expected) {
      final label = CropLabel.parse(raw);
      expect((label.crop, label.condition, label.isHealthy), expected,
          reason: raw);
      expect(label.isNotACrop, isFalse);
    });
  });

  test('recognises not_a_crop', () {
    final label = CropLabel.parse('not_a_crop');
    expect(label.isNotACrop, isTrue);
    expect(label.isHealthy, isFalse);
  });

  test('normalize matches labels that differ only in separators and case',
      () {
    expect(CropLabel.normalize('Corn_(maize)___Common_rust_'),
        CropLabel.normalize('corn maize common rust'));
  });
}
