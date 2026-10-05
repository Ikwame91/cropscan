import 'dart:convert';

import 'package:cropscan_pro/core/ml/classification_result.dart';
import 'package:cropscan_pro/data/knowledge/crop_label.dart';

/// One saved scan.
///
/// Disease details are deliberately *not* stored here: [rawLabel] is the key
/// into `crop_database.json`, so updates to the database show up in old
/// scans too.
class CropDetection {
  final String id;

  /// The model label, e.g. `Tomato_Early_blight`.
  final String rawLabel;

  /// Display name at the time of the scan, e.g. "Tomato - Early Blight".
  final String cropName;
  final double confidence;

  /// Local file path of the saved photo.
  final String imageUrl;
  final DateTime detectedAt;

  /// "Healthy" or "Disease Detected".
  final String status;
  final String? location;
  final String? notes;

  /// Runner-up predictions, best first.
  final List<LabelScore> alternatives;

  /// True when the user chose to keep a low-confidence prediction.
  final bool isUncertain;

  const CropDetection({
    required this.id,
    required this.rawLabel,
    required this.cropName,
    required this.confidence,
    required this.imageUrl,
    required this.detectedAt,
    required this.status,
    this.location,
    this.notes,
    this.alternatives = const [],
    this.isUncertain = false,
  });

  CropLabel get label => CropLabel.parse(rawLabel);

  /// The crop alone, e.g. "Tomato", for grouping scans of the same plants.
  String get crop => label.crop;

  bool get isHealthy => label.isHealthy;
  bool get isDiseaseDetected => !isHealthy;

  /// Reads both the current format and records written by earlier versions
  /// of the app (which used `rawDetectedCrop` and embedded the whole
  /// database entry).
  factory CropDetection.fromMap(
    Map<String, dynamic> map, {
    String? Function(String displayName)? recoverRawLabel,
  }) {
    final cropName = map['cropName'] as String? ?? '';
    final rawLabel = map['rawLabel'] as String? ??
        map['rawDetectedCrop'] as String? ??
        recoverRawLabel?.call(cropName) ??
        cropName;

    return CropDetection(
      id: map['id']?.toString() ?? '',
      rawLabel: rawLabel,
      cropName: cropName,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '',
      detectedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['detectedAt'] as num?)?.toInt() ?? 0,
      ),
      status: map['status'] as String? ?? '',
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      alternatives: [
        for (final alt in (map['alternatives'] as List? ?? const []))
          LabelScore.fromMap(Map<String, dynamic>.from(alt as Map)),
      ],
      isUncertain: map['isUncertain'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'rawLabel': rawLabel,
        'cropName': cropName,
        'confidence': confidence,
        'imageUrl': imageUrl,
        'detectedAt': detectedAt.millisecondsSinceEpoch,
        'status': status,
        'location': location,
        'notes': notes,
        'alternatives': alternatives.map((a) => a.toMap()).toList(),
        'isUncertain': isUncertain,
      };

  CropDetection copyWith({String? notes, String? location}) => CropDetection(
        id: id,
        rawLabel: rawLabel,
        cropName: cropName,
        confidence: confidence,
        imageUrl: imageUrl,
        detectedAt: detectedAt,
        status: status,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        alternatives: alternatives,
        isUncertain: isUncertain,
      );

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'CropDetection($id, $rawLabel, ${(confidence * 100).toStringAsFixed(1)}%)';
}
