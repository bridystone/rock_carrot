import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';

extension SqlHandlerRocks on SqlHandler {
  FutureOr<int> deleteRocks(int sektorid) {
    return database.then(
      (db) => db.delete(
        SqlHandler.rocksTablename,
        where: 'sektorid = ?',
        whereArgs: [sektorid],
      ),
    );
  }

  Future<List<Map<String, Object?>>> queryRocks(
    int sektorid,
  ) {
    return database.then((db) => db.rawQuery(
          'SELECT gipfel_ID, gipfelnr, gipfelname_d, gipfelname_cz, '
          '   status, typ, schartenhoehe, talhoehe, gipfel.sektorid, '
          '   COUNT(wege.gipfelid) as count'
          ' FROM gipfel'
          '   LEFT OUTER JOIN wege'
          '   ON gipfel.gipfel_ID = wege.gipfelid'
          ' WHERE gipfel.sektorid = ?'
          ' GROUP BY gipfel.gipfel_id'
          ' ORDER BY gipfelnr',
          [sektorid],
        ));
  }
}
