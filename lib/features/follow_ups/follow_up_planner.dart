import 'package:cropscan_pro/data/models/crop_detection.dart';
import 'package:cropscan_pro/data/models/disease_info.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_task.dart';

/// Turns a diagnosis into a dated care plan, using the treatment intervals
/// and monitoring frequency from `crop_database.json`.
class FollowUpPlanner {
  static const int defaultReapplyDays = 7;
  static const int recoveryCheckDays = 14;
  static const int healthyCheckDays = 7;

  /// Extracts an interval in days from free text such as
  /// "spray every 7-10 days", "Spray weekly." or "Spray bi-weekly.".
  /// Ranges use the lower bound so reminders are never late.
  static int? parseIntervalDays(String? text) {
    if (text == null) return null;
    final t = text.toLowerCase();

    final days =
        RegExp(r'every\s+(\d+)(?:\s*[-–]\s*\d+)?\s*days?').firstMatch(t);
    if (days != null) return int.parse(days.group(1)!);

    final weeks =
        RegExp(r'every\s+(\d+)(?:\s*[-–]\s*\d+)?\s*weeks?').firstMatch(t);
    if (weeks != null) return int.parse(weeks.group(1)!) * 7;

    if (RegExp(r'bi-?weekly|fortnight').hasMatch(t)) return 14;
    if (t.contains('weekly') || t.contains('every week')) return 7;
    if (t.contains('daily') || t.contains('every day')) return 1;
    return null;
  }

  /// Builds the care plan for [detection]. Returns an empty list for scans
  /// that don't need one (e.g. "not a crop").
  static List<FollowUpTask> plan({
    required CropDetection detection,
    required DiseaseInfo? info,
    required DateTime now,
    required String Function() newId,
  }) {
    if (detection.label.isNotACrop) return const [];

    final today = DateTime(now.year, now.month, now.day);
    DateTime inDays(int d) => today.add(Duration(days: d));

    FollowUpTask task(
      FollowUpType type,
      String title,
      DateTime due, [
      List<String> details = const [],
    ]) =>
        FollowUpTask(
          id: newId(),
          detectionId: detection.id,
          rawLabel: detection.rawLabel,
          crop: detection.crop,
          title: title,
          details: details,
          type: type,
          dueDate: due,
          createdAt: now,
        );

    final crop = detection.crop;

    if (detection.isUncertain) {
      return [
        task(
          FollowUpType.rescan,
          'Rescan $crop with a clearer photo',
          today,
          const [
            'Photograph a single leaf in daylight, filling the frame.',
            'Avoid shadows, blur and background clutter.',
          ],
        ),
      ];
    }

    if (detection.isHealthy) {
      return [
        task(
          FollowUpType.rescan,
          'Routine $crop check-up scan',
          inDays(healthyCheckDays),
          const ['Scan a few leaves from different parts of the field.'],
        ),
      ];
    }

    final disease = info?.basicInfo.displayName ?? detection.cropName;
    final treatment = info?.treatment;
    final tasks = <FollowUpTask>[
      task(
        FollowUpType.treat,
        'Start treating $disease',
        today,
        treatment?.immediateAction ??
            const ['Remove and destroy affected leaves.'],
      ),
    ];

    final sprayTexts = [
      ...?treatment?.organicSolutions.map((s) => s.application ?? s.timing),
      ...?treatment?.chemicalSolutions.map((s) => s.timing),
    ];
    final sprayIntervals = sprayTexts
        .map(parseIntervalDays)
        .whereType<int>()
        .where((d) => d >= 3)
        .toList()
      ..sort();
    final hasSprays = (treatment?.organicSolutions.isNotEmpty ?? false) ||
        (treatment?.chemicalSolutions.isNotEmpty ?? false);

    if (hasSprays) {
      final reapplyDays =
          sprayIntervals.isEmpty ? defaultReapplyDays : sprayIntervals.first;
      tasks.add(task(
        FollowUpType.reapply,
        'Re-apply treatment for $disease',
        inDays(reapplyDays),
        [
          for (final s in treatment!.organicSolutions.take(1))
            [s.method, s.application].whereType<String>().join(' — '),
          for (final s in treatment.chemicalSolutions.take(1))
            s.activeIngredient,
        ],
      ));
    }

    final monitoring = info?.monitoring;
    final inspectEvery = parseIntervalDays(monitoring?.inspectionFrequency);
    if (monitoring != null && monitoring.keyIndicators.isNotEmpty) {
      // Daily scouting advice becomes a check in a few days, not a daily nag.
      final inspectDays = (inspectEvery ?? 7).clamp(3, 7);
      tasks.add(task(
        FollowUpType.inspect,
        'Inspect $crop plants for spread',
        inDays(inspectDays),
        [
          for (final k in monitoring.keyIndicators) 'Look for: $k',
          if (monitoring.actionThreshold != null)
            'Act when: ${monitoring.actionThreshold}',
        ],
      ));
    }

    tasks.add(task(
      FollowUpType.rescan,
      'Rescan $crop to check recovery',
      inDays(recoveryCheckDays),
      const ['Scan the same plants to see whether treatment is working.'],
    ));

    return tasks;
  }
}
