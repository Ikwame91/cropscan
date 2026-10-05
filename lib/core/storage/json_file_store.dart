import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Reads and writes one JSON document in the app's documents directory.
///
/// Writes go to a temporary file that is then renamed over the original, so
/// a crash mid-write can't leave a half-written (unparseable) file behind.
class JsonFileStore {
  final String fileName;
  final Future<Directory> Function() _directory;

  JsonFileStore(this.fileName, {Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationDocumentsDirectory;

  Future<File> _file() async => File('${(await _directory()).path}/$fileName');

  /// Returns the decoded JSON, or null if the file doesn't exist yet.
  Future<Object?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) return null;
    return json.decode(contents);
  }

  Future<void> write(Object? data) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(json.encode(data), flush: true);
    await temp.rename(file.path);
  }

  Future<void> delete() async {
    final file = await _file();
    if (await file.exists()) await file.delete();
  }
}
