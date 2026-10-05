import 'dart:io';

import 'package:cropscan_pro/core/storage/json_file_store.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/data/models/crop_detection.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_provider.dart';
import 'package:cropscan_pro/features/follow_ups/follow_up_task.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  final repo = DiseaseKnowledgeRepository.fromJsonString(
      File('assets/data/crop_database.json').readAsStringSync());
  var now = DateTime(2026, 10, 5, 9);

  setUp(() {
    dir = Directory.systemTemp.createTempSync('followups');
    now = DateTime(2026, 10, 5, 9);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  FollowUpProvider provider() => FollowUpProvider(
        store: JsonFileStore('f.json', directory: () async => dir),
        clock: () => now,
        autoLoad: false,
      );

  CropDetection scan(String id, String label, {bool uncertain = false}) =>
      CropDetection(
        id: id,
        rawLabel: label,
        cropName: repo.displayNameFor(label),
        confidence: 0.9,
        imageUrl: '/x.jpg',
        detectedAt: now,
        status: '',
        isUncertain: uncertain,
      );

  test('creates a plan once per scan and persists it', () async {
    final p = provider();
    final s = scan('a', 'Tomato_Early_blight');
    final first = await p.createPlan(s, repo.lookup(s.rawLabel));
    final again = await p.createPlan(s, repo.lookup(s.rawLabel));
    expect(again.length, first.length);
    expect(p.tasks.length, first.length);

    final reloaded = provider();
    await reloaded.load();
    expect(reloaded.tasks.length, first.length);
  });

  test('due and overdue tasks move as days pass', () async {
    final p = provider();
    await p.createPlan(
        scan('a', 'Tomato_Early_blight'), repo.lookup('Tomato_Early_blight'));
    expect(p.dueNow.single.type, FollowUpType.treat);
    expect(p.overdueCount, 0);

    now = now.add(const Duration(days: 8));
    expect(p.overdueCount, greaterThanOrEqualTo(2));
    await p.complete(p.dueNow.first.id);
    expect(p.completed, hasLength(1));
  });

  test('scanning the same crop again closes its rescan task', () async {
    final p = provider();
    await p.createPlan(
        scan('a', 'Tomato_Early_blight'), repo.lookup('Tomato_Early_blight'));
    await p.recordRescan(scan('b', 'Tomato_healthy'));
    final rescan = p.tasks.firstWhere((t) => t.type == FollowUpType.rescan);
    expect(rescan.isDone, isTrue);
    expect(rescan.outcome, contains('Healthy'));

    // A different crop leaves it alone.
    await p.createPlan(scan('c', 'Corn_(maize)___Common_rust_'),
        repo.lookup('Corn_(maize)___Common_rust_'));
    await p.recordRescan(scan('d', 'Tomato_healthy'));
    expect(
        p
            .forDetection('c')
            .firstWhere((t) => t.type == FollowUpType.rescan)
            .isDone,
        isFalse);
  });

  test('an uncertain rescan leaves the recovery check open', () async {
    final p = provider();
    await p.createPlan(
        scan('a', 'Tomato_Early_blight'), repo.lookup('Tomato_Early_blight'));
    await p.recordRescan(scan('b', 'Tomato_healthy', uncertain: true));
    expect(p.tasks.firstWhere((t) => t.type == FollowUpType.rescan).isDone,
        isFalse);
  });

  test('snooze moves a task to tomorrow', () async {
    final p = provider();
    await p.createPlan(
        scan('a', 'Tomato_Early_blight'), repo.lookup('Tomato_Early_blight'));
    final treat = p.dueNow.single;
    await p.snooze(treat.id);
    expect(p.dueNow, isEmpty);
    expect(p.upcoming.first.dueDate, DateTime(2026, 10, 6));
  });

  test('removing a scan removes its plan', () async {
    final p = provider();
    await p.createPlan(
        scan('a', 'Tomato_Early_blight'), repo.lookup('Tomato_Early_blight'));
    await p.removeForDetections({'a'});
    expect(p.tasks, isEmpty);
  });

  test('history events drive the care plan', () async {
    final followUps = provider();
    final history = DetectionHistoryProvider(
      repo,
      store: JsonFileStore('h.json', directory: () async => dir),
      imagesRoot: () async => dir,
      autoLoad: false,
    )
      ..addDetectionAddedListener(followUps.recordRescan)
      ..addDetectionsRemovedListener(followUps.removeForDetections);

    final sick = await history.addDetection(
        rawLabel: 'Tomato_Early_blight', confidence: 0.9, imagePath: '/x');
    await followUps.createPlan(sick!, repo.lookup(sick.rawLabel));

    await history.addDetection(
        rawLabel: 'Tomato_healthy', confidence: 0.9, imagePath: '/y');
    expect(
        followUps.tasks.firstWhere((t) => t.type == FollowUpType.rescan).isDone,
        isTrue);

    await history.clearAllHistory();
    expect(followUps.tasks, isEmpty);
  });
}
