import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';

extension SqlHandlerSubareas on SqlHandler {
  FutureOr<int> deleteSubareasIncludingComments(int gebietid) {
    return database.then((db) {
      // delete comments
      db.delete(
        SqlHandler.commentsTablename,
        where: 'gebietid = ?',
        whereArgs: [gebietid],
      );
      // delete subareas
      return db.delete(
        SqlHandler.subareasTablename,
        where: 'gebietid = ?',
        whereArgs: [gebietid],
      );
    });
  }

  Future<List<Map<String, Object?>>> querySubareas(int gebietid) {
    return database.then((db) => db.rawQuery(
          'SELECT sektor_ID, sektornr, sektorname_d, sektorname_cz, COUNT(gipfel.sektorid) as count'
          ' FROM teilgebiet'
          ' LEFT OUTER JOIN gipfel'
          ' ON teilgebiet.sektor_ID = gipfel.sektorid'
          ' WHERE gebietid = ?'
          ' GROUP BY teilgebiet.sektor_ID',
          [gebietid],
        ));
  }
}
