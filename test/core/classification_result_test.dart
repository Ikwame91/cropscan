import 'package:cropscan_pro/core/ml/classification_result.dart';
import 'package:flutter_test/flutter_test.dart';

const labels = ['Tomato_Early_blight', 'Tomato_Late_blight', 'Tomato_healthy', 'not_a_crop'];

ClassificationResult classify(List<double> p) =>
    ClassificationResult.fromProbabilities(p, labels);

void main() {
  test('confident when the top crop class is clear', () {
    final r = classify([0.90, 0.05, 0.03, 0.02]);
    expect(r.outcome, ClassificationOutcome.confident);
    expect(r.top.label, 'Tomato_Early_blight');
  });

  test('uncertain between the minimum and confident thresholds', () {
    expect(classify([0.60, 0.30, 0.05, 0.05]).outcome,
        ClassificationOutcome.uncertain);
  });

  test('uncertain when "not a crop" is a strong runner-up', () {
    expect(classify([0.78, 0.0, 0.0, 0.22]).outcome,
        ClassificationOutcome.uncertain);
  });

  test('not a crop when it is the top class or the crop score is very low',
      () {
    expect(classify([0.1, 0.1, 0.1, 0.7]).outcome,
        ClassificationOutcome.notACrop);
    expect(classify([0.35, 0.33, 0.32, 0.0]).outcome,
        ClassificationOutcome.notACrop);
  });

  test('alternatives skip "not a crop" and negligible scores', () {
    final r = classify([0.60, 0.25, 0.01, 0.14]);
    expect(r.alternatives().map((a) => a.label), ['Tomato_Late_blight']);
  });

  test('rejects a probability vector that does not match the labels', () {
    expect(() => classify([1.0]), throwsArgumentError);
  });
}
