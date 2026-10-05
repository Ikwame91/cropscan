import 'dart:convert';
import 'dart:io';

import 'package:cropscan_pro/core/storage/json_file_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('store'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('overlapping writes are queued and the last one wins', () async {
    final store = JsonFileStore('data.json', directory: () async => dir);
    final data = <int>[];
    final writes = <Future<void>>[];
    for (var i = 0; i < 25; i++) {
      data.add(i);
      writes.add(store.write(List.of(data)));
    }
    await Future.wait(writes);
    expect(await store.read(), List.generate(25, (i) => i));
    expect(File('${dir.path}/data.json.tmp').existsSync(), isFalse);
  });

  test('writes the data as it was when write was called', () async {
    final store = JsonFileStore('data.json', directory: () async => dir);
    final data = <String, Object>{'v': 1};
    final pending = store.write(data);
    data['v'] = 2;
    await pending;
    expect(await store.read(), {'v': 1});
  });

  test('a failed write does not block later ones', () async {
    final store = JsonFileStore('data.json', directory: () async => dir);
    await expectLater(
        store.write(Object()), throwsA(isA<JsonUnsupportedObjectError>()));
    await store.write([1]);
    expect(await store.read(), [1]);
  });
}
