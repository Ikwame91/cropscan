class FarmingAlert {
  final String id;
  final String title;
  final String message;
  final String priority; // e.g., "critical", "high", "medium", "low"
  final String
      type; // e.g., "irrigation", "weather", "fertilizer", "pest", "disease", "harvest"
  final DateTime timestamp;
  bool isRead; // This will be mutable as its state can change

  FarmingAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.type,
    required this.timestamp,
    this.isRead = false, // Default to unread
  });

  // Factory constructor for creating a FarmingAlert from a map (e.g., from JSON/Firestore)
  factory FarmingAlert.fromMap(Map<String, dynamic> map) {
    return FarmingAlert(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      priority: map['priority'] as String,
      type: map['type'] as String,
      timestamp: DateTime.parse(
          map['timestamp'] as String), // Assuming ISO 8601 string
      isRead: map['isRead'] as bool,
    );
  }

  // Method for converting a FarmingAlert to a map (e.g., for sending to JSON/Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'priority': priority,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  // For easy copying with some fields changed (useful for updates)
  FarmingAlert copyWith({
    String? id,
    String? title,
    String? message,
    String? priority,
    String? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return FarmingAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
