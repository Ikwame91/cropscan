import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Reads and writes one JSON document in the app's documents directory.
///
/// Writes go to a temporary file that is then renamed over the original, so
/// a crash mid-write can't leave a half-written (unparseable) file behind.
/// Writes are queued, so overlapping calls can't race on the temporary file;
/// the last call's data always wins.
class JsonFileStore {
  final String fileName;
  final Future<Directory> Function() _directory;
  Future<void> _lastWrite = Future.value();

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

  Future<void> write(Object? data) {
    // Encode now so the data written is what the caller passed, even if the
    // caller mutates it while an earlier write is still in progress.
    final String encoded;
    try {
      encoded = json.encode(data);
    } catch (e, stack) {
      return Future.error(e, stack);
    }
    final write = _lastWrite.then((_) => _writeNow(encoded));
    _lastWrite = write.catchError((Object _) {});
    return write;
  }

  Future<void> _writeNow(String encoded) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(encoded, flush: true);
    await temp.rename(file.path);
  }

  Future<void> delete() async {
    final file = await _file();
    if (await file.exists()) await file.delete();
  }
}
