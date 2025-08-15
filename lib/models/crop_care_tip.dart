class CropCareTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> cropTypes;
  final String severity;
  final String iconName;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> preventions;
  final String? imageAsset;
  final bool isSeasonal;
  final List<int> relevantMonths; // 1-12 for months

  const CropCareTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cropTypes,
    required this.severity,
    required this.iconName,
    required this.symptoms,
    required this.treatments,
    required this.preventions,
    this.imageAsset,
    this.isSeasonal = false,
    this.relevantMonths = const [],
  });

  bool isRelevantForCrop(String cropName) {
    return cropTypes
        .any((crop) => cropName.toLowerCase().contains(crop.toLowerCase()));
  }

  bool isRelevantForCurrentMonth() {
    if (!isSeasonal || relevantMonths.isEmpty) return true;
    return relevantMonths.contains(DateTime.now().month);
  }

  factory CropCareTip.fromMap(Map<String, dynamic> map) {
    return CropCareTip(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      severity: map['severity'] ?? 'medium',
      iconName: map['iconName'] ?? 'help',
      symptoms: List<String>.from(map['symptoms'] ?? []),
      treatments: List<String>.from(map['treatments'] ?? []),
      preventions: List<String>.from(map['preventions'] ?? []),
      imageAsset: map['imageAsset'],
      isSeasonal: map['isSeasonal'] ?? false,
      relevantMonths: List<int>.from(map['relevantMonths'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'cropTypes': cropTypes,
      'severity': severity,
      'iconName': iconName,
      'symptoms': symptoms,
      'treatments': treatments,
      'preventions': preventions,
      'imageAsset': imageAsset,
      'isSeasonal': isSeasonal,
      'relevantMonths': relevantMonths,
    };
  }
}
