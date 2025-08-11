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

  EnhancedCropInfo({
    required this.basicInfo,
    this.symptoms,
    this.causes,
    this.treatment,
    this.prevention,
    this.maintenance,
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
    );
  }
}

class EconomicImpact {
  final String? yieldLoss;
  final String? qualityImpact;
  final String? treatmentCost;
  final String? criticalPeriod;

  EconomicImpact({
    this.yieldLoss,
    this.qualityImpact,
    this.treatmentCost,
    this.criticalPeriod,
  });

  factory EconomicImpact.fromJson(Map<String, dynamic> json) {
    return EconomicImpact(
      yieldLoss: json['yield_loss'],
      qualityImpact: json['quality_impact'],
      treatmentCost: json['treatment_cost'],
      criticalPeriod: json['critical_period'],
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

  static EnhancedCropInfo? getCropInfo(String rawLabel) {
    if (_cropDatabase == null || !_isInitialized) {
      if (kDebugMode) {
        print(
            '⚠️ Warning: Crop database is not initialized or failed to load.');
      }
      return null;
    }

    final cropData = _cropDatabase!['crop_diseases'][rawLabel];
    if (cropData == null) {
      print('⚠️ Warning: No data found for label: $rawLabel');
      // Print available keys for debugging
      print(
          'Available crops: ${_cropDatabase!['crop_diseases'].keys.take(5).join(', ')}...');
      return null;
    }

    try {
      return EnhancedCropInfo.fromJson(cropData);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing crop data for $rawLabel: $e');
      }
      return null;
    }
  }
}
