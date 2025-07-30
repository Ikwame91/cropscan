// lib/models/crop_detection.dart
class CropDetection {
  final String id;
  final String cropName;
  final double confidence;
  final String imageUrl;
  final DateTime detectedAt;
  final String status; // e.g., "Healthy", "Disease Detected", "Pest Detected"

  CropDetection({
    required this.id,
    required this.cropName,
    required this.confidence,
    required this.imageUrl,
    required this.detectedAt,
    required this.status,
  });

  // Factory constructor for creating a CropDetection from a map (e.g., from JSON/Firestore)
  factory CropDetection.fromMap(Map<String, dynamic> map) {
    return CropDetection(
      id: map['id'] as String,
      cropName: map['cropName'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
      detectedAt: DateTime.parse(
          map['detectedAt'] as String), // Assuming ISO 8601 string
      status: map['status'] as String,
    );
  }

  // Method for converting a CropDetection to a map (e.g., for sending to JSON/Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'detectedAt': detectedAt.toIso8601String(),
      'status': status,
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
  }) {
    return CropDetection(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      detectedAt: detectedAt ?? this.detectedAt,
      status: status ?? this.status,
    );
  }
}
