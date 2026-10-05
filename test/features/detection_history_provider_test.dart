import 'dart:io';

import 'package:cropscan_pro/core/ml/classification_result.dart';
import 'package:cropscan_pro/core/storage/json_file_store.dart';
import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:cropscan_pro/features/history/detection_history_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late DiseaseKnowledgeRepository repo;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('history_test');
    repo = DiseaseKnowledgeRepository.fromJsonString(
        File('assets/data/crop_database.json').readAsStringSync());
  });
  tearDown(() => dir.deleteSync(recursive: true));

  DetectionHistoryProvider provider() => DetectionHistoryProvider(
        repo,
        store: JsonFileStore('history.json', directory: () async => dir),
        imagesRoot: () async => dir,
        autoLoad: false,
      );

  test('saves a scan with its label and reloads it after a restart', () async {
    final photo = File('${dir.path}/photo.jpg')..writeAsBytesSync([1, 2, 3]);
    final first = provider();
    final saved = await first.addDetection(
      rawLabel: 'Tomato_Early_blight',
      confidence: 0.82,
      imagePath: photo.path,
      alternatives: const [LabelScore('Tomato_Late_blight', 0.1)],
    );

    expect(saved!.cropName, 'Tomato - Early Blight');
    expect(saved.isDiseaseDetected, isTrue);
    expect(saved.imageUrl, isNot(photo.path), reason: 'photo is copied');

    final second = provider();
    await second.loadDetectionHistory();
    final reloaded = second.byId(saved.id)!;
    expect(reloaded.rawLabel, 'Tomato_Early_blight');
    expect(reloaded.alternatives.single.label, 'Tomato_Late_blight');
  });

  test('reads records written by the previous app version', () async {
    final legacy = File('${dir.path}/history.json');
    legacy.writeAsStringSync('''[
      {"id": "1", "cropName": "Tomato - Early Blight", "confidence": 0.9,
       "imageUrl": "/missing.jpg", "detectedAt": 1700000000000,
       "status": "Disease Detected", "location": "Farm Location",
       "enhancedCropInfo": {"basic_info": {"display_name": "x"}}}
    ]''');
    final p = provider();
    await p.loadDetectionHistory();
    expect(p.detectionHistory.single.rawLabel, 'Tomato_Early_blight');
    expect(p.errorMessage, isNull);
  });

  test('deletes scans and their photos', () async {
    final photo = File('${dir.path}/photo.jpg')..writeAsBytesSync([1]);
    final p = provider();
    final saved = await p.addDetection(
        rawLabel: 'Tomato_healthy', confidence: 0.9, imagePath: photo.path);
    await p.deleteDetection(saved!.id);
    expect(p.detectionHistory, isEmpty);
    expect(File(saved.imageUrl).existsSync(), isFalse);
  });
}
