import 'package:cropscan_pro/core/storage/json_file_store.dart';
import 'package:cropscan_pro/data/models/crop_detection.dart';
import 'package:cropscan_pro/data/models/disease_info.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_planner.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_task.dart';
import 'package:flutter/foundation.dart';

/// Care-plan tasks created from diagnoses, persisted to `follow_ups.json`.
class FollowUpProvider extends ChangeNotifier {
  final JsonFileStore _store;
  final DateTime Function() _clock;

  List<FollowUpTask> _tasks = [];
  bool _isLoading = false;
  int _idCounter = 0;

  FollowUpProvider({
    JsonFileStore? store,
    DateTime Function()? clock,
    bool autoLoad = true,
  })  : _store = store ?? JsonFileStore('follow_ups.json'),
        _clock = clock ?? DateTime.now {
    if (autoLoad) load();
  }

  bool get isLoading => _isLoading;
  DateTime get now => _clock();

  List<FollowUpTask> get tasks => List.unmodifiable(_tasks);

  List<FollowUpTask> get pending =>
      _sorted(_tasks.where((t) => !t.isDone).toList());

  /// Due today or overdue — what the farmer should do now.
  List<FollowUpTask> get dueNow =>
      _sorted(_tasks.where((t) => t.isDueBy(now)).toList());

  List<FollowUpTask> get upcoming =>
      _sorted(_tasks.where((t) => !t.isDone && !t.isDueBy(now)).toList());

  List<FollowUpTask> get completed => _tasks.where((t) => t.isDone).toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  int get overdueCount => _tasks.where((t) => t.isOverdue(now)).length;

  List<FollowUpTask> forDetection(String detectionId) =>
      _sorted(_tasks.where((t) => t.detectionId == detectionId).toList());

  bool hasPlanFor(String detectionId) =>
      _tasks.any((t) => t.detectionId == detectionId);

  static List<FollowUpTask> _sorted(List<FollowUpTask> list) =>
      list..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _store.read();
      _tasks = [
        for (final item in (data as List? ?? const []))
          FollowUpTask.fromMap(Map<String, dynamic>.from(item as Map)),
      ];
    } catch (e) {
      debugPrint('FollowUpProvider: failed to load tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      await _store.write(_tasks.map((t) => t.toMap()).toList());
    } catch (e) {
      debugPrint('FollowUpProvider: failed to save tasks: $e');
    }
  }

  String _newId() => '${now.microsecondsSinceEpoch}_${_idCounter++}';

  /// Creates the care plan for a diagnosis. Does nothing if one already
  /// exists for that scan. Returns the plan's tasks.
  Future<List<FollowUpTask>> createPlan(
    CropDetection detection,
    DiseaseInfo? info,
  ) async {
    if (hasPlanFor(detection.id)) return forDetection(detection.id);
    final plan = FollowUpPlanner.plan(
      detection: detection,
      info: info,
      now: now,
      newId: _newId,
    );
    if (plan.isEmpty) return const [];
    _tasks.addAll(plan);
    notifyListeners();
    await _persist();
    return plan;
  }

  /// Closes open "rescan" tasks for the same crop when it's scanned again.
  /// An uncertain scan can't confirm recovery, so it closes nothing.
  Future<void> recordRescan(CropDetection detection) async {
    if (detection.isUncertain) return;
    var changed = false;
    for (var i = 0; i < _tasks.length; i++) {
      final t = _tasks[i];
      if (!t.isDone &&
          t.type == FollowUpType.rescan &&
          t.crop == detection.crop &&
          t.detectionId != detection.id) {
        _tasks[i] = t.copyWith(
          completedAt: now,
          outcome: 'Rescanned: ${detection.cropName}',
        );
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> complete(String taskId) => _update(
        taskId,
        (t) => t.copyWith(completedAt: now),
      );

  Future<void> reopen(String taskId) => _update(
        taskId,
        (t) => t.copyWith(clearCompleted: true),
      );

  Future<void> snooze(String taskId, {int days = 1}) => _update(
        taskId,
        (t) {
          final today = DateTime(now.year, now.month, now.day);
          return t.copyWith(dueDate: today.add(Duration(days: days)));
        },
      );

  Future<void> _update(
    String taskId,
    FollowUpTask Function(FollowUpTask) change,
  ) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return;
    _tasks[i] = change(_tasks[i]);
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
    await _persist();
  }

  /// Removes plans belonging to scans that were deleted from history.
  Future<void> removeForDetections(Iterable<String> detectionIds) async {
    final ids = detectionIds.toSet();
    final before = _tasks.length;
    _tasks.removeWhere((t) => ids.contains(t.detectionId));
    if (_tasks.length != before) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> clearAll() async {
    _tasks.clear();
    notifyListeners();
    await _persist();
  }
}
