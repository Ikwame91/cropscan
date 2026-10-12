import 'dart:convert';

import 'package:cropscan_pro/data/knowledge/crop_label.dart';
import 'package:cropscan_pro/data/models/disease_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// One entry of `crop_database.json`, keyed by the model label it describes.
class DiseaseEntry {
  final String rawLabel;
  final CropLabel label;
  final DiseaseInfo info;

  const DiseaseEntry(this.rawLabel, this.label, this.info);

  String get displayName => info.displayName;
  String get crop => label.crop;
  bool get isHealthy => label.isHealthy;
}

extension DiseaseInfoX on DiseaseInfo {
  String get displayName => basicInfo.displayName;
  bool get isHealthy => basicInfo.condition.toLowerCase() == 'healthy';

  Color get statusColor {
    final hex = basicInfo.statusColor.replaceFirst('#', '');
    final value = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
    return Color(value ?? 0xFF4CAF50);
  }

  /// A one-paragraph summary suitable for a results card.
  String get summary {
    if (isHealthy) {
      return 'No disease detected. Keep up regular care and scouting.';
    }
    final first = symptoms?.earlyStage.firstOrNull;
    return first ??
        '${basicInfo.diseaseType} disease of ${basicInfo.cropType}'.trim();
  }

  /// The single most important next step for the farmer.
  String get firstAction {
    if (isHealthy) {
      return maintenance?.watering?.frequency ??
          'Continue regular watering, feeding and weekly scouting.';
    }
    return treatment?.immediateAction.firstOrNull ??
        'Remove affected leaves and consult your local extension officer.';
  }
}

/// Single source of truth for crop/disease information, loaded once from
/// `assets/data/crop_database.json`.
class DiseaseKnowledgeRepository {
  static const String assetPath = 'assets/data/crop_database.json';

  final Map<String, DiseaseEntry> _byLabel = {};
  final Map<String, DiseaseEntry> _byNormalizedLabel = {};
  final Map<String, DiseaseEntry> _byDisplayName = {};

  DiseaseKnowledgeRepository._();

  /// Builds a repository directly from the database JSON (used by tests).
  factory DiseaseKnowledgeRepository.fromJsonString(String source) {
    final repo = DiseaseKnowledgeRepository._();
    final decoded = json.decode(source) as Map<String, dynamic>;
    final diseases = decoded['crop_diseases'] as Map<String, dynamic>;
    for (final MapEntry(:key, :value) in diseases.entries) {
      try {
        final entry = DiseaseEntry(
          key,
          CropLabel.parse(key),
          DiseaseInfo.fromJson(value as Map<String, dynamic>),
        );
        repo._byLabel[key] = entry;
        repo._byNormalizedLabel[CropLabel.normalize(key)] = entry;
        final name = entry.displayName.toLowerCase();
        repo._byDisplayName[name] = entry;
        // Earlier app versions dropped a repeated crop word:
        // "Tomato - Tomato Mosaic Virus" was saved as "Tomato - Mosaic Virus".
        final repeated = RegExp(r'^(.+?) - \1 ').firstMatch(name);
        if (repeated != null) {
          final legacy =
              '${repeated.group(1)} - ${name.substring(repeated.end)}';
          repo._byDisplayName.putIfAbsent(legacy, () => entry);
        }
      } catch (e) {
        debugPrint('DiseaseKnowledgeRepository: skipping "$key": $e');
      }
    }
    return repo;
  }

  static Future<DiseaseKnowledgeRepository> load([AssetBundle? bundle]) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    return DiseaseKnowledgeRepository.fromJsonString(source);
  }

  List<DiseaseEntry> get entries => List.unmodifiable(_byLabel.values);

  List<DiseaseEntry> get diseases =>
      entries.where((e) => !e.isHealthy).toList(growable: false);

  /// Crops covered by the database, e.g. ["Bell Pepper", "Maize", "Tomato"].
  List<String> get crops =>
      (entries.map((e) => e.crop).toSet().toList()..sort());

  DiseaseEntry? entryFor(String rawLabel) =>
      _byLabel[rawLabel] ?? _byNormalizedLabel[CropLabel.normalize(rawLabel)];

  DiseaseInfo? lookup(String rawLabel) => entryFor(rawLabel)?.info;

  /// Older history records only stored the display name. This recovers
  /// their model label so they can be linked back to the database.
  String? rawLabelForDisplayName(String displayName) =>
      _byDisplayName[displayName.toLowerCase()]?.rawLabel;

  /// Human-readable name for a label, whether or not it's in the database.
  String displayNameFor(String rawLabel) =>
      lookup(rawLabel)?.displayName ?? CropLabel.parse(rawLabel).displayName;
}
