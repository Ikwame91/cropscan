import 'dart:io';

import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/data/models/crop_detection.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_planner.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = DiseaseKnowledgeRepository.fromJsonString(
      File('assets/data/crop_database.json').readAsStringSync());
  final now = DateTime(2026, 10, 5, 14, 30);
  final today = DateTime(2026, 10, 5);
  var ids = 0;

  CropDetection scan(String label, {bool uncertain = false}) => CropDetection(
        id: 'scan-$label',
        rawLabel: label,
        cropName: repo.displayNameFor(label),
        confidence: 0.9,
        imageUrl: '/x.jpg',
        detectedAt: now,
        status: '',
        isUncertain: uncertain,
      );

  List<FollowUpTask> plan(String label, {bool uncertain = false}) =>
      FollowUpPlanner.plan(
        detection: scan(label, uncertain: uncertain),
        info: repo.lookup(label),
        now: now,
        newId: () => '${ids++}',
      );

  group('parseIntervalDays', () {
    final cases = {
      'Mix according to label and spray on leaves every 7-10 days': 7,
      'Spray 2g/liter every 5-7 days during wet weather': 5,
      'Every 7 days.': 7,
      'spray weekly': 7,
      'Spray bi-weekly.': 14,
      'Daily in wet weather.': 1,
      'every 2 weeks': 14,
      'Apply 5-10 tons/ha': null,
      null: null,
    };
    cases.forEach((text, days) {
      test('"$text" → $days', () {
        expect(FollowUpPlanner.parseIntervalDays(text), days);
      });
    });
  });

  test('a disease gets treat, re-apply, inspect and rescan tasks', () {
    final tasks = plan('Corn_(maize)___Common_rust_');
    expect(tasks.map((t) => t.type), [
      FollowUpType.treat,
      FollowUpType.reapply,
      FollowUpType.inspect,
      FollowUpType.rescan,
    ]);
    expect(tasks.first.dueDate, today);
    expect(tasks.first.details, isNotEmpty, reason: 'immediate actions');
    // "spray every 7 days" in the database.
    expect(tasks[1].dueDate, today.add(const Duration(days: 7)));
    expect(tasks.last.dueDate, today.add(const Duration(days: 14)));
    expect(tasks.every((t) => t.crop == 'Maize'), isTrue);
  });

  test('re-apply uses the shortest spray interval in the database', () {
    // Pepper bacterial spot: "every 5-7 days" and "weekly".
    final reapply = plan('Pepper__bell___Bacterial_spot')
        .firstWhere((t) => t.type == FollowUpType.reapply);
    expect(reapply.dueDate, today.add(const Duration(days: 5)));
  });

  test('daily scouting becomes a check in 3 days, not a daily task', () {
    final inspect = plan('Tomato_Late_blight')
        .firstWhere((t) => t.type == FollowUpType.inspect);
    expect(inspect.dueDate, today.add(const Duration(days: 3)));
  });

  test('every disease in the database produces a plan', () {
    for (final entry in repo.diseases) {
      final tasks = plan(entry.rawLabel);
      expect(tasks.first.type, FollowUpType.treat, reason: entry.rawLabel);
      expect(tasks.last.type, FollowUpType.rescan, reason: entry.rawLabel);
    }
  });

  test('a healthy crop gets one check-up scan next week', () {
    final tasks = plan('Tomato_healthy');
    expect(tasks.single.type, FollowUpType.rescan);
    expect(tasks.single.dueDate, today.add(const Duration(days: 7)));
  });

  test('an uncertain scan gets one rescan today', () {
    final tasks = plan('Tomato_Early_blight', uncertain: true);
    expect(tasks.single.type, FollowUpType.rescan);
    expect(tasks.single.dueDate, today);
  });
}
