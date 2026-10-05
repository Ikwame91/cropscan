import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final labels = File('assets/ml_models/labels.txt')
      .readAsLinesSync()
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  final database = (json.decode(
              File('assets/data/crop_database.json').readAsStringSync())
          as Map<String, dynamic>)['crop_diseases'] as Map<String, dynamic>;

  test('model has the expected 17 classes', () {
    expect(labels, hasLength(17));
    expect(labels, contains('not_a_crop'));
  });

  test('every crop label has an entry in crop_database.json', () {
    final missing = labels
        .where((l) => l != 'not_a_crop' && !database.containsKey(l))
        .toList();
    expect(missing, isEmpty);
  });

  test('every database entry has basic info', () {
    for (final MapEntry(:key, :value) in database.entries) {
      final basic = (value as Map<String, dynamic>)['basic_info'];
      expect(basic, isNotNull, reason: key);
      expect(basic['display_name'], isNotEmpty, reason: key);
      expect(basic['condition'], isNotEmpty, reason: key);
    }
  });
}
