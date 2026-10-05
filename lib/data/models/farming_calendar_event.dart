class FarmingCalendarEvent {
  final String id;
  final String title;
  final String description;
  final List<String> cropTypes;
  final int month;
  final String category; // planting, harvesting, care, prevention
  final String priority; // high, medium, low
  final List<String> actionItems;
  final String region; // Ghana-specific regions

  const FarmingCalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.cropTypes,
    required this.month,
    required this.category,
    required this.priority,
    required this.actionItems,
    this.region = 'all',
  });

  bool isRelevantForCurrentMonth() {
    return month == DateTime.now().month;
  }

  bool isRelevantForCrop(String cropName) {
    return cropTypes.isEmpty ||
        cropTypes
            .any((crop) => cropName.toLowerCase().contains(crop.toLowerCase()));
  }

  factory FarmingCalendarEvent.fromMap(Map<String, dynamic> map) {
    return FarmingCalendarEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      month: map['month'] ?? 1,
      category: map['category'] ?? 'care',
      priority: map['priority'] ?? 'medium',
      actionItems: List<String>.from(map['actionItems'] ?? []),
      region: map['region'] ?? 'all',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cropTypes': cropTypes,
      'month': month,
      'category': category,
      'priority': priority,
      'actionItems': actionItems,
      'region': region,
    };
  }
}
