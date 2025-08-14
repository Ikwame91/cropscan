import 'package:cropscan_pro/models/enhanced_crop_info.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../models/crop_detection.dart';

class DetectionHistoryProvider extends ChangeNotifier {
  List<CropDetection> _detectionHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CropDetection> get detectionHistory =>
      List.unmodifiable(_detectionHistory);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Statistics
  int get totalScans => _detectionHistory.length;
  double get averageConfidence {
    if (_detectionHistory.isEmpty) return 0.0;
    return _detectionHistory.map((d) => d.confidence).reduce((a, b) => a + b) /
        _detectionHistory.length;
  }

  String get mostIdentifiedCrop {
    if (_detectionHistory.isEmpty) return 'None';

    Map<String, int> cropCounts = {};
    for (var detection in _detectionHistory) {
      cropCounts[detection.cropName] =
          (cropCounts[detection.cropName] ?? 0) + 1;
    }

    return cropCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // Initialize and load saved history
  DetectionHistoryProvider() {
    loadDetectionHistory();
  }

  // Add new detection to history
  Future<void> addDetection({
    required String cropName,
    required double confidence,
    required String imagePath,
    required String status,
    required EnhancedCropInfo enhancedCropInfo,
    String? rawDetectedCrop,
    String? location,
    String? notes,
  }) async {
    try {
      // Save image to permanent storage
      final savedImagePath = await _saveImagePermanently(imagePath);

      final detection = CropDetection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropName: cropName,
        confidence: confidence,
        imageUrl: savedImagePath,
        detectedAt: DateTime.now(),
        status: status,
        enhancedCropInfo: enhancedCropInfo,
        rawDetectedCrop: rawDetectedCrop,
        location: location ?? "Uknown Location",
        notes: notes,
      );

      _detectionHistory.insert(0, detection); // Add to beginning
      await _saveDetectionHistory();

      debugPrint("✅ Detection added to history: $cropName");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error adding detection to history: $e");
      _errorMessage = 'Failed to save detection: $e';
      notifyListeners();
    }
  }

  Future<void> updateDetection(CropDetection updatedDetection) async {
    try {
      final index =
          _detectionHistory.indexWhere((d) => d.id == updatedDetection.id);
      if (index != -1) {
        _detectionHistory[index] = updatedDetection;
        await _saveDetectionHistory();
        debugPrint("✅ Detection updated: ${updatedDetection.cropName}");
        notifyListeners();
      } else {
        debugPrint(
            "⚠️ Warning: Could not find detection to update with id: ${updatedDetection.id}");
      }
    } catch (e) {
      debugPrint("❌ Error updating detection in history: $e");
      _errorMessage = 'Failed to update detection: $e';
      notifyListeners();
    }
  }

  // Load detection history from storage
  Future<void> loadDetectionHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/detection_history.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);

        _detectionHistory = jsonList
            .map((json) => CropDetection.fromMap(json as Map<String, dynamic>))
            .toList();

        // Sort by date (newest first)
        _detectionHistory.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

        debugPrint("✅ Loaded ${_detectionHistory.length} detection records");
      } else {
        debugPrint("📝 No existing detection history found");
        _detectionHistory = [];
      }
    } catch (e) {
      debugPrint("❌ Error loading detection history: $e");
      _errorMessage = 'Failed to load detection history: $e';
      _detectionHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save detection history to storage
  Future<void> _saveDetectionHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/detection_history.json');
      final jsonList =
          _detectionHistory.map((detection) => detection.toMap()).toList();
      final jsonString = json.encode(jsonList);
      debugPrint("Saving JSON: $jsonString"); // Debug content
      await file.writeAsString(jsonString);
      debugPrint("✅ Detection history saved successfully");
    } catch (e) {
      debugPrint("❌ Error saving detection history: $e");
      _errorMessage = 'Failed to save detection history: $e';
      notifyListeners();
    }
  }

  // Save image to permanent app storage
  Future<String> _saveImagePermanently(String tempImagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/detection_images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final originalFile = File(tempImagePath);

      // Check if the original file exists
      if (!await originalFile.exists()) {
        throw Exception('Source image file does not exist: $tempImagePath');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newPath = '${imagesDir.path}/$fileName';

      await originalFile.copy(newPath);

      final copiedFile = File(newPath);
      if (!await copiedFile.exists()) {
        throw Exception('Failed to copy image to permanent location');
      }

      debugPrint("✅ Image saved permanently: $newPath");
      debugPrint("✅ Image file size: ${await copiedFile.length()} bytes");

      debugPrint("✅ Image saved permanently: $newPath");

      return newPath;
    } catch (e) {
      debugPrint("❌ Error saving image permanently: $e");
      debugPrint("❌ Source path: $tempImagePath");

      return tempImagePath;
    }
  }

  // Delete detection from history
  Future<void> deleteDetection(String detectionId) async {
    try {
      final detectionToDelete =
          _detectionHistory.firstWhere((d) => d.id == detectionId);

      // Delete image file
      final imageFile = File(detectionToDelete.imageUrl);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      _detectionHistory.removeWhere((d) => d.id == detectionId);
      await _saveDetectionHistory();

      debugPrint("✅ Detection deleted: $detectionId");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error deleting detection: $e");
      _errorMessage = 'Failed to delete detection: $e';
      notifyListeners();
    }
  }

  // Delete multiple detections
  Future<void> deleteMultipleDetections(List<String> detectionIds) async {
    try {
      for (String id in detectionIds) {
        final detection = _detectionHistory.firstWhere((d) => d.id == id);

        // Delete image file
        final imageFile = File(detection.imageUrl);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      _detectionHistory.removeWhere((d) => detectionIds.contains(d.id));
      await _saveDetectionHistory();

      debugPrint("✅ ${detectionIds.length} detections deleted");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error deleting multiple detections: $e");
      _errorMessage = 'Failed to delete detections: $e';
      notifyListeners();
    }
  }

  // Clear all history
  Future<void> clearAllHistory() async {
    try {
      // Delete all image files
      for (var detection in _detectionHistory) {
        final imageFile = File(detection.imageUrl);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      _detectionHistory.clear();
      await _saveDetectionHistory();

      debugPrint("✅ All detection history cleared");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error clearing history: $e");
      _errorMessage = 'Failed to clear history: $e';
      notifyListeners();
    }
  }

  // Filter methods
  List<CropDetection> getFilteredHistory({
    String? searchQuery,
    String? cropFilter,
    double? confidenceThreshold,
    DateTimeRange? dateRange,
  }) {
    List<CropDetection> filtered = List.from(_detectionHistory);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((detection) {
        return detection.cropName
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (cropFilter != null && cropFilter.isNotEmpty) {
      filtered = filtered.where((detection) {
        return detection.cropName
            .toLowerCase()
            .contains(cropFilter.toLowerCase());
      }).toList();
    }

    if (confidenceThreshold != null) {
      filtered = filtered.where((detection) {
        return detection.confidence >= confidenceThreshold;
      }).toList();
    }

    if (dateRange != null) {
      filtered = filtered.where((detection) {
        return detection.detectedAt.isAfter(dateRange.start) &&
            detection.detectedAt.isBefore(dateRange.end.add(Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  // Get recent detections for dashboard
  List<CropDetection> getRecentDetections({int limit = 5}) {
    return _detectionHistory.take(limit).toList();
  }

  // Convert CropDetection to Map for widget compatibility
  Map<String, dynamic> toMap(CropDetection detection) {
    return {
      'id': detection.id,
      'cropName': detection.cropName,
      'cropType': _getCropType(detection.cropName),
      'imageUrl': detection.imageUrl,
      'confidence': detection.confidence,
      'timestamp': detection.detectedAt,
      'status': detection.status,
      'location':
          detection.location ?? 'Unknown Location', // Handle null location
      'diseaseDetected': detection.status.toLowerCase().contains('disease'),
      'pestDetected': detection.status.toLowerCase().contains('pest'),
      'imageExists': File(detection.imageUrl).existsSync(),
    };
  }

  // Dummy implementation for crop type
  String _getCropType(String cropName) {
    // TODO: Replace with real crop type mapping
    return 'Type of $cropName';
  }
}
