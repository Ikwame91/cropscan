import 'package:cropscan_pro/models/crop_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

// Main crop information model
class EnhancedCropInfo {
  final BasicInfo basicInfo;
  final Symptoms? symptoms;
  final Causes? causes;
  final Treatment? treatment;
  final Prevention? prevention;
  final Maintenance? maintenance;

  final MonitoringInfo? monitoring;
  final String? localTipsGhana;

  EnhancedCropInfo({
    required this.basicInfo,
    this.symptoms,
    this.causes,
    this.treatment,
    this.prevention,
    this.maintenance,
    this.monitoring,
    this.localTipsGhana,
  });

  factory EnhancedCropInfo.fromJson(Map<String, dynamic> json) {
    return EnhancedCropInfo(
      basicInfo: BasicInfo.fromJson(json['basic_info']),
      symptoms:
          json['symptoms'] != null ? Symptoms.fromJson(json['symptoms']) : null,
      causes: json['causes'] != null ? Causes.fromJson(json['causes']) : null,
      treatment: json['treatment'] != null
          ? Treatment.fromJson(json['treatment'])
          : null,
      prevention: json['prevention'] != null
          ? Prevention.fromJson(json['prevention'])
          : null,
      maintenance: json['maintenance'] != null
          ? Maintenance.fromJson(json['maintenance'])
          : null,
      monitoring: json['monitoring'] != null
          ? MonitoringInfo.fromJson(json['monitoring'])
          : null,
      localTipsGhana: json['local_tips_ghana'],
    );
  }
}

class EnhancedCropInfoService {
  static Map<String, dynamic>? _cropDatabase;
  static bool _isInitialized = false;

  static Future<void> loadDatabase() async {
    if (_isInitialized) {
      return;
    }
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/crop_database.json');
      _cropDatabase = json.decode(jsonString);
      _isInitialized = true;
      if (kDebugMode) {
        print('✅ Crop database loaded successfully!');
      }
      if (kDebugMode) {
        print(
            '📊 Loaded ${_cropDatabase!['crop_diseases'].length} crop entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading crop database: $e');
      }
      _cropDatabase = null;
    }
  }
// Update the getCropInfo method:

  static EnhancedCropInfo? getCropInfo(String rawLabel) {
    if (_cropDatabase == null || !_isInitialized) {
      if (kDebugMode) {
        print(
            '⚠️ Warning: Crop database is not initialized or failed to load.');
      }
      return null;
    }

    // Debug: Print what we're looking for and what's available
    if (kDebugMode) {
      print('🔍 Searching for: "$rawLabel"');
      print(
          '📚 Database has ${_cropDatabase!['crop_diseases'].length} entries');
      print('🔑 Available keys (first 10):');
      _cropDatabase!['crop_diseases'].keys.take(10).forEach((key) {
        print('  - "$key"');
      });
    }

    // Try exact match first
    var cropData = _cropDatabase!['crop_diseases'][rawLabel];

    if (cropData == null) {
      // Try different variations of the label
      final variations = [
        rawLabel.replaceAll(' ', '_'),
        rawLabel.replaceAll('_', ' '),
        rawLabel.toLowerCase(),
        rawLabel.toUpperCase(),
        '${rawLabel}_',
        rawLabel.replaceAll(' ', '_('),
        // Add more specific variations based on your JSON structure
        'Corn_(maize)___${rawLabel.replaceAll(' ', '_')}',
        'Tomato___${rawLabel.replaceAll(' ', '_')}',
      ];

      if (kDebugMode) {
        print('🔄 Trying variations:');
      }

      for (String variation in variations) {
        if (kDebugMode) {
          print('  Trying: "$variation"');
        }
        cropData = _cropDatabase!['crop_diseases'][variation];
        if (cropData != null) {
          if (kDebugMode) {
            print('✅ Found match with variation: "$variation"');
          }
          break;
        }
      }
    }

    if (cropData == null) {
      if (kDebugMode) {
        print('❌ No data found for label: "$rawLabel"');
        print('💡 Suggestion: Check if the key exists in your JSON file');
      }
      return null;
    }

    try {
      if (kDebugMode) {
        print('✅ Parsing crop data for: "$rawLabel"');
      }
      return EnhancedCropInfo.fromJson(cropData);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing crop data for "$rawLabel": $e');
        print('📄 Raw data structure: ${cropData.keys}');
      }
      return null;
    }
  }
}
