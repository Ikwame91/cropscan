enum FollowUpType {
  /// Carry out the immediate treatment steps.
  treat,

  /// Re-apply a spray/treatment after its interval.
  reapply,

  /// Walk the field and look for specific signs.
  inspect,

  /// Take a new photo to check recovery. Completed automatically when the
  /// same crop is scanned again.
  rescan,
}

/// A dated reminder generated from a diagnosis.
class FollowUpTask {
  final String id;
  final String detectionId;
  final String rawLabel;

  /// Crop the task is about, e.g. "Tomato".
  final String crop;
  final String title;
  final List<String> details;
  final FollowUpType type;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Optional outcome, e.g. "Rescanned: Tomato - Healthy".
  final String? outcome;

  const FollowUpTask({
    required this.id,
    required this.detectionId,
    required this.rawLabel,
    required this.crop,
    required this.title,
    required this.type,
    required this.dueDate,
    required this.createdAt,
    this.details = const [],
    this.completedAt,
    this.outcome,
  });

  bool get isDone => completedAt != null;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  bool isOverdue(DateTime now) => !isDone && _day(dueDate).isBefore(_day(now));
  bool isDueToday(DateTime now) => !isDone && _day(dueDate) == _day(now);
  bool isDueBy(DateTime now) => !isDone && !_day(dueDate).isAfter(_day(now));

  FollowUpTask copyWith({
    DateTime? completedAt,
    bool clearCompleted = false,
    String? outcome,
    DateTime? dueDate,
  }) =>
      FollowUpTask(
        id: id,
        detectionId: detectionId,
        rawLabel: rawLabel,
        crop: crop,
        title: title,
        details: details,
        type: type,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt,
        completedAt: clearCompleted ? null : (completedAt ?? this.completedAt),
        outcome: clearCompleted ? null : (outcome ?? this.outcome),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'detectionId': detectionId,
        'rawLabel': rawLabel,
        'crop': crop,
        'title': title,
        'details': details,
        'type': type.name,
        'dueDate': dueDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'outcome': outcome,
      };

  factory FollowUpTask.fromMap(Map<String, dynamic> map) => FollowUpTask(
        id: map['id'] as String,
        detectionId: map['detectionId'] as String,
        rawLabel: map['rawLabel'] as String,
        crop: map['crop'] as String,
        title: map['title'] as String,
        details: List<String>.from(map['details'] as List? ?? const []),
        type: FollowUpType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => FollowUpType.inspect,
        ),
        dueDate: DateTime.parse(map['dueDate'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
        completedAt: map['completedAt'] == null
            ? null
            : DateTime.parse(map['completedAt'] as String),
        outcome: map['outcome'] as String?,
      );
}
