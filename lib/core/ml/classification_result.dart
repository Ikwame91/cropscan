import 'package:cropscan_pro/data/knowledge/crop_label.dart';

/// How the app should treat a model prediction.
enum ClassificationOutcome {
  /// Top class is a crop condition and the model is confident.
  confident,

  /// Top class is a crop condition but confidence is low, or "not a crop"
  /// is a close runner-up. The user should be shown the alternatives.
  uncertain,

  /// The image most likely doesn't show a supported crop leaf.
  notACrop,
}

class LabelScore {
  final String label;
  final double confidence;

  const LabelScore(this.label, this.confidence);

  bool get isNotACrop => CropLabel.parse(label).isNotACrop;

  Map<String, dynamic> toMap() => {'label': label, 'confidence': confidence};

  factory LabelScore.fromMap(Map<String, dynamic> map) => LabelScore(
        map['label'] as String,
        (map['confidence'] as num).toDouble(),
      );

  @override
  String toString() =>
      'LabelScore($label, ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// The interpreted output of one model run.
///
/// Kept free of Flutter/TFLite imports so the decision rules can be unit
/// tested directly.
class ClassificationResult {
  /// Confidence at or above which a crop prediction is trusted.
  static const double confidentThreshold = 0.75;

  /// Below this the top crop prediction is treated as "not a crop".
  static const double minimumCropThreshold = 0.40;

  /// If "not a crop" scores at least this much, a crop prediction is
  /// downgraded to uncertain even when it clears [confidentThreshold].
  static const double notACropRunnerUpThreshold = 0.20;

  /// All classes, highest confidence first.
  final List<LabelScore> ranked;
  final ClassificationOutcome outcome;

  const ClassificationResult._(this.ranked, this.outcome);

  LabelScore get top => ranked.first;

  /// Other crop conditions worth showing next to [top], best first.
  List<LabelScore> alternatives({int count = 2, double minConfidence = 0.05}) {
    return ranked
        .skip(1)
        .where((s) => !s.isNotACrop && s.confidence >= minConfidence)
        .take(count)
        .toList();
  }

  factory ClassificationResult.fromProbabilities(
    List<double> probabilities,
    List<String> labels,
  ) {
    if (probabilities.isEmpty || probabilities.length != labels.length) {
      throw ArgumentError(
        'Expected ${labels.length} probabilities, got ${probabilities.length}',
      );
    }

    final ranked = [
      for (var i = 0; i < labels.length; i++)
        LabelScore(labels[i], probabilities[i]),
    ]..sort((a, b) => b.confidence.compareTo(a.confidence));

    final top = ranked.first;
    final notACropScore = ranked
        .firstWhere((s) => s.isNotACrop, orElse: () => const LabelScore('', 0))
        .confidence;

    final ClassificationOutcome outcome;
    if (top.isNotACrop || top.confidence < minimumCropThreshold) {
      outcome = ClassificationOutcome.notACrop;
    } else if (top.confidence < confidentThreshold ||
        notACropScore >= notACropRunnerUpThreshold) {
      outcome = ClassificationOutcome.uncertain;
    } else {
      outcome = ClassificationOutcome.confident;
    }

    return ClassificationResult._(List.unmodifiable(ranked), outcome);
  }
}
