import 'dart:io';

import 'package:cropscan_pro/core/storage/json_file_store.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/features/guide/crop_care_provider.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = DiseaseKnowledgeRepository.fromJsonString(
      File('assets/data/crop_database.json').readAsStringSync());
  final guide = File('assets/data/farming_guide.json').readAsStringSync();
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('guide'));
  tearDown(() => dir.deleteSync(recursive: true));

  Future<CropCareProvider> provider(DateTime now) async {
    final p = CropCareProvider(repo,
        loadGuide: () async => guide, clock: () => now, autoLoad: false);
    await p.refreshData();
    return p;
  }

  Future<DetectionHistoryProvider> historyWith(List<String> labels) async {
    final h = DetectionHistoryProvider(
      repo,
      store: JsonFileStore('h.json', directory: () async => dir),
      imagesRoot: () async => dir,
      autoLoad: false,
    );
    for (final label in labels) {
      await h.addDetection(rawLabel: label, confidence: 0.9, imagePath: '/x');
    }
    return h;
  }

  test('loads the guide asset', () async {
    final p = await provider(DateTime(2026, 3, 1));
    expect(p.errorMessage, isNull);
    expect(p.calendarEvents, hasLength(9));
    expect(p.getTipsByCategory('care'), isNotEmpty);
  });

  test('the disease library covers every disease in the database', () async {
    final p = await provider(DateTime(2026, 3, 1));
    final diseases = p.getTipsByCategory('disease');
    expect(diseases, hasLength(repo.diseases.length));
    for (final tip in diseases) {
      expect(repo.lookup(CropCareProvider.rawLabelOf(tip)!), isNotNull);
    }
  });

  test('personalised tips lead with diseases from recent scans', () async {
    final p = await provider(DateTime(2026, 3, 1));
    final history = await historyWith(['Tomato_Late_blight', 'Tomato_healthy']);
    final tips = p.getPersonalizedTips(history);
    expect(CropCareProvider.rawLabelOf(tips.first), 'Tomato_Late_blight');
    expect(tips.where((t) => t.category == 'disease'), hasLength(1));
    expect(tips.every((t) => t.isRelevantForCrop('tomato')), isTrue);
  });

  test('without history, general tips are shown', () async {
    final p = await provider(DateTime(2026, 3, 1));
    final tips = p.getPersonalizedTips(null);
    expect(tips, isNotEmpty);
    expect(tips.any((t) => t.category == 'disease'), isFalse);
  });

  test('calendar shows this month, or the next month with entries', () async {
    final march = await provider(DateTime(2026, 3, 15));
    expect(
        march.getRelevantActivities(null).every((e) => e.month == 3), isTrue);

    // No entries for October in the guide: fall forward to December.
    final october = await provider(DateTime(2026, 10, 5));
    final events = october.getRelevantActivities(null);
    expect(events, isNotEmpty);
    expect(events.first.month, 12);
  });

  test('calendar filters to the crops scanned', () async {
    final p = await provider(DateTime(2026, 4, 10));
    final history = await historyWith(['Pepper__bell___healthy']);
    final events = p.getRelevantActivities(history);
    expect(events.every((e) => e.isRelevantForCrop('bell pepper')), isTrue);
  });

  test('a broken guide file reports an error instead of crashing', () async {
    final p = CropCareProvider(repo,
        loadGuide: () async => '{not json', autoLoad: false);
    await p.refreshData();
    expect(p.errorMessage, isNotNull);
    expect(p.getTipsByCategory('disease'), isNotEmpty,
        reason: 'disease tips come from the database');
  });
}
