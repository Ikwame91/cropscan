import 'dart:io';

import 'package:cropscan_pro/data/knowledge/disease_knowledge_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = DiseaseKnowledgeRepository.fromJsonString(
      File('assets/data/crop_database.json').readAsStringSync());
  final labels = File('assets/ml_models/labels.txt')
      .readAsLinesSync()
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && l != 'not_a_crop');

  test('every model label resolves to database info', () {
    for (final label in labels) {
      expect(repo.lookup(label), isNotNull, reason: label);
    }
  });

  test('lookup tolerates separator and case differences', () {
    expect(repo.lookup('corn (maize) common rust'), isNotNull);
  });

  test('recovers the label of a legacy record from its display name', () {
    final entry = repo.entryFor('Tomato_Early_blight')!;
    expect(repo.rawLabelForDisplayName(entry.displayName),
        'Tomato_Early_blight');
  });

  test('parses the top-level monitoring block', () {
    final monitoring = repo.lookup('Tomato_Early_blight')!.monitoring!;
    expect(monitoring.inspectionFrequency, isNotEmpty);
    expect(monitoring.keyIndicators, isNotEmpty);
  });

  test('healthy entries are flagged and diseases exclude them', () {
    expect(repo.lookup('Tomato_healthy')!.isHealthy, isTrue);
    expect(repo.diseases.any((e) => e.isHealthy), isFalse);
    expect(repo.crops, ['Bell Pepper', 'Maize', 'Tomato']);
  });

  test('falls back to a parsed name for unknown labels', () {
    expect(repo.displayNameFor('Tomato_Brand_new_disease'),
        'Tomato - Brand New Disease');
  });
}
