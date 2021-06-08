import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

final String cacheSubDirectory = '/cache/';
// /data/data/info.breidenstein.rock_carrot/app_flutter/cache/

class CacheData {
  /// generate App Cache Path
  Future<Directory> get _cacheDirectory async {
    final fhDir = Directory(
        (await getApplicationDocumentsDirectory()).path + cacheSubDirectory);
    if (!await fhDir.exists()) {
      await fhDir.create(recursive: true);
    }
    // print(fhDir.absolute.toString());
    return fhDir;
  }

  Future<String?> caching(
      String prefix, int id, Future<String?> Function(int) fetchData) async {
    String? rockResponse;
    if ((rockResponse = await getFromStorage('$prefix$id')) == null) {
      rockResponse = await fetchData(id);
      // react on timeout -> return null to upper function
      if (rockResponse == null) {
        return null;
      }
      await putToStorage('$prefix$id', rockResponse);
    }
    return rockResponse;
  }

  /// remove all cached data
  Future<void> clearCache() async {
    final fhDir = await _cacheDirectory;
    await fhDir.delete(recursive: true);
    return Future.value();
  }

  Future<String?> getFromStorage(String id) async {
    final fhDir = await _cacheDirectory;
    final fhStore = File(fhDir.absolute.path + '$id.bin');
    if (await fhStore.exists()) {
      return fhStore.readAsString();
    }
    return null;
  }

  Future<String> putToStorage(String id, String content) async {
    final fhDir = await _cacheDirectory;
    final fhStore = File(fhDir.absolute.path + '$id.bin');
    await fhStore.writeAsString(content);
    return content;
  }
}
