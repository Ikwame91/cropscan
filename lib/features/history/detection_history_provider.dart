import 'dart:io';

import 'package:cropscan_pro/core/ml/classification_result.dart';
import 'package:cropscan_pro/core/storage/json_file_store.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/data/models/crop_detection.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Saved scans, newest first, persisted to `detection_history.json`.
class DetectionHistoryProvider extends ChangeNotifier {
  final DiseaseKnowledgeRepository _knowledge;
  final JsonFileStore _store;
  final Future<Directory> Function() _imagesRoot;

  List<CropDetection> _detectionHistory = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  DetectionHistoryProvider(
    this._knowledge, {
    JsonFileStore? store,
    Future<Directory> Function()? imagesRoot,
    bool autoLoad = true,
  })  : _store = store ?? JsonFileStore('detection_history.json'),
        _imagesRoot = imagesRoot ?? getApplicationDocumentsDirectory {
    if (autoLoad) loadDetectionHistory();
  }

  List<CropDetection> get detectionHistory =>
      List.unmodifiable(_detectionHistory);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  int get totalScans => _detectionHistory.length;
  int get healthyCount => _detectionHistory.where((d) => d.isHealthy).length;
  int get issueCount => totalScans - healthyCount;

  double get averageConfidence {
    if (_detectionHistory.isEmpty) return 0.0;
    return _detectionHistory.map((d) => d.confidence).reduce((a, b) => a + b) /
        _detectionHistory.length;
  }

  String get mostIdentifiedCrop {
    if (_detectionHistory.isEmpty) return 'None';
    final counts = <String, int>{};
    for (final d in _detectionHistory) {
      counts[d.crop] = (counts[d.crop] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Crops the user has actually scanned, e.g. {"Tomato", "Maize"}.
  Set<String> get scannedCrops => _detectionHistory.map((d) => d.crop).toSet();

  /// Disease labels found in the user's recent scans, most recent first.
  List<String> recentDiseaseLabels({int scans = 20}) => _detectionHistory
      .take(scans)
      .where((d) => d.isDiseaseDetected)
      .map((d) => d.rawLabel)
      .toSet()
      .toList();

  CropDetection? byId(String id) {
    for (final d in _detectionHistory) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Saves a new scan (copying the photo into app storage) and returns it.
  Future<CropDetection?> addDetection({
    required String rawLabel,
    required double confidence,
    required String imagePath,
    List<LabelScore> alternatives = const [],
    bool isUncertain = false,
    String? location,
    String? notes,
  }) async {
    try {
      final info = _knowledge.lookup(rawLabel);
      final detection = CropDetection(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        rawLabel: rawLabel,
        cropName: _knowledge.displayNameFor(rawLabel),
        confidence: confidence,
        imageUrl: await _saveImagePermanently(imagePath),
        detectedAt: DateTime.now(),
        status: info?.basicInfo.condition ??
            (rawLabel.toLowerCase().contains('healthy')
                ? 'Healthy'
                : 'Disease Detected'),
        alternatives: alternatives,
        isUncertain: isUncertain,
        location: location,
        notes: notes,
      );

      _detectionHistory.insert(0, detection);
      notifyListeners();
      await _persist();
      return detection;
    } catch (e) {
      debugPrint('DetectionHistoryProvider: failed to add detection: $e');
      _errorMessage = 'Failed to save detection: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> updateDetection(CropDetection updated) async {
    final index = _detectionHistory.indexWhere((d) => d.id == updated.id);
    if (index == -1) return;
    _detectionHistory[index] = updated;
    notifyListeners();
    await _persist();
  }

  Future<void> loadDetectionHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _store.read();
      _detectionHistory = [
        for (final item in (data as List? ?? const []))
          CropDetection.fromMap(
            Map<String, dynamic>.from(item as Map),
            recoverRawLabel: _knowledge.rawLabelForDisplayName,
          ),
      ]..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    } catch (e) {
      debugPrint('DetectionHistoryProvider: failed to load history: $e');
      _errorMessage = 'Failed to load detection history: $e';
      _detectionHistory = [];
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      await _store.write(_detectionHistory.map((d) => d.toMap()).toList());
    } catch (e) {
      debugPrint('DetectionHistoryProvider: failed to save history: $e');
      _errorMessage = 'Failed to save detection history: $e';
      notifyListeners();
    }
  }

  Future<String> _saveImagePermanently(String tempImagePath) async {
    final source = File(tempImagePath);
    if (!await source.exists()) return tempImagePath;

    try {
      final dir = Directory('${(await _imagesRoot()).path}/detection_images');
      await dir.create(recursive: true);
      final saved = await source.copy(
        '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      return saved.path;
    } catch (e) {
      debugPrint('DetectionHistoryProvider: could not copy image: $e');
      return tempImagePath;
    }
  }

  Future<void> _deleteImage(CropDetection detection) async {
    try {
      final file = File(detection.imageUrl);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('DetectionHistoryProvider: could not delete image: $e');
    }
  }

  Future<void> deleteDetection(String detectionId) =>
      deleteMultipleDetections([detectionId]);

  Future<void> deleteMultipleDetections(List<String> detectionIds) async {
    final ids = detectionIds.toSet();
    final removed = _detectionHistory.where((d) => ids.contains(d.id)).toList();
    _detectionHistory.removeWhere((d) => ids.contains(d.id));
    notifyListeners();
    await _persist();
    for (final d in removed) {
      await _deleteImage(d);
    }
  }

  Future<void> clearAllHistory() async {
    final removed = List.of(_detectionHistory);
    _detectionHistory.clear();
    notifyListeners();
    await _persist();
    for (final d in removed) {
      await _deleteImage(d);
    }
  }

  List<CropDetection> getFilteredHistory({
    String? searchQuery,
    String? cropFilter,
    double? confidenceThreshold,
    DateTimeRange? dateRange,
  }) {
    final query = searchQuery?.toLowerCase() ?? '';
    final crop = cropFilter?.toLowerCase() ?? '';
    return _detectionHistory.where((d) {
      if (query.isNotEmpty && !d.cropName.toLowerCase().contains(query)) {
        return false;
      }
      if (crop.isNotEmpty && !d.cropName.toLowerCase().contains(crop)) {
        return false;
      }
      if (confidenceThreshold != null && d.confidence < confidenceThreshold) {
        return false;
      }
      if (dateRange != null &&
          (d.detectedAt.isBefore(dateRange.start) ||
              !d.detectedAt
                  .isBefore(dateRange.end.add(const Duration(days: 1))))) {
        return false;
      }
      return true;
    }).toList();
  }

  List<CropDetection> getRecentDetections({int limit = 5}) =>
      _detectionHistory.take(limit).toList();
}
