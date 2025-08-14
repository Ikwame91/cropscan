import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:cropscan_pro/models/enhanced_crop_info.dart';

class CropDetection {
  final String id;
  final String cropName;
  final double confidence;
  final String imageUrl;
  final DateTime detectedAt;
  final String status;
  final String? location;
  final String? notes;
  final String? rawDetectedCrop;
  final EnhancedCropInfo? enhancedCropInfo;
  CropDetection({
    required this.id,
    required this.cropName,
    required this.confidence,
    required this.imageUrl,
    required this.detectedAt,
    required this.status,
    this.location,
    this.notes,
    this.enhancedCropInfo,
    this.rawDetectedCrop,
  });

  // Factory constructor for creating a CropDetection from a map (e.g., from JSON/Firestore)
  factory CropDetection.fromMap(Map<String, dynamic> map) {
    return CropDetection(
      id: map['id'] ?? '',
      cropName: map['cropName'] ?? '',
      confidence: map['confidence']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      detectedAt: DateTime.fromMillisecondsSinceEpoch(map['detectedAt']),
      status: map['status'] ?? '',
      location: map['location'],
      notes: map['notes'],
      rawDetectedCrop: map['rawDetectedCrop'],
      enhancedCropInfo: map['enhancedCropInfo'] != null
          ? EnhancedCropInfo.fromMap(map['enhancedCropInfo'])
          : null,
    );
  }

  // Method for converting a CropDetection to a map (e.g., for sending to JSON/Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'detectedAt': detectedAt.millisecondsSinceEpoch,
      'status': status,
      'location': location,
      'notes': notes,
      'enhancedCropInfo': enhancedCropInfo?.toMap(),
    };
  }

  // For easy copying with some fields changed (useful for updates)
  CropDetection copyWith({
    String? id,
    String? cropName,
    double? confidence,
    String? imageUrl,
    DateTime? detectedAt,
    String? status,
    ValueGetter<String?>? location,
    ValueGetter<String?>? notes,
    ValueGetter<EnhancedCropInfo?>? enhancedCropInfo,
  }) {
    return CropDetection(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      detectedAt: detectedAt ?? this.detectedAt,
      status: status ?? this.status,
      location: location != null ? location() : this.location,
      notes: notes != null ? notes() : this.notes,
      enhancedCropInfo:
          enhancedCropInfo != null ? enhancedCropInfo() : this.enhancedCropInfo,
    );
  }

  String toJson() => json.encode(toMap());

  factory CropDetection.fromJson(String source) =>
      CropDetection.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CropDetection(id: $id, cropName: $cropName, confidence: $confidence, imageUrl: $imageUrl, detectedAt: $detectedAt, status: $status, location: $location, notes: $notes, enhancedCropInfo: $enhancedCropInfo)';
  }
}
