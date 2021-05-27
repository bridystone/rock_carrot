import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';

extension SqlHandlerRocks on SqlHandler {
  Future<int> deleteRocksIncludingSubitems(int sektorid) {
    return database.then((db) {
      // delete route comments
      db.rawDelete(
        'DELETE FROM ${SqlHandler.commentsTablename}'
        ' WHERE wegid IN ('
        '   SELECT weg_id'
        '   FROM ${SqlHandler.routesTablename}'
        '   WHERE gipfelid IN ('
        '     SELECT gipfel_id'
        '     FROM ${SqlHandler.rocksTablename}'
        '     WHERE sektorid = ?'
        '   )'
        ' )',
        [sektorid],
      );
      // delete rock comments
      db.rawDelete(
        'DELETE FROM ${SqlHandler.commentsTablename}'
        ' WHERE gipfelid IN ('
        '   SELECT gipfel_id'
        '   FROM ${SqlHandler.rocksTablename}'
        '   WHERE sektorid = ?'
        ' )',
        [sektorid],
      );
      // delete subarea comments
      db.delete(
        SqlHandler.commentsTablename,
        where: 'sektorid = ?',
        whereArgs: [sektorid],
      );
      // delete routes
      db.rawDelete(
        'DELETE'
        ' FROM ${SqlHandler.routesTablename}'
        ' WHERE gipfelid IN ('
        '   SELECT gipfel_id'
        '   FROM ${SqlHandler.rocksTablename}'
        '   WHERE sektorid = ?'
        ' )',
        [sektorid],
      );
      // delete rocks
      return db.delete(
        SqlHandler.rocksTablename,
        where: 'sektorid = ?',
        whereArgs: [sektorid],
      );
    });
  }

  // TODO: add comment count
  Future<List<Map<String, Object?>>> queryRocks(
    int sektorid,
  ) {
    return database.then((db) => db.rawQuery(
          'SELECT'
          ' gipfel.*,'
          ' COUNT(DISTINCT wege.weg_id) as wege_count,'
          ' COUNT(DISTINCT komment.komment_id) as komment_count'
          ' FROM gipfel'
          '   LEFT OUTER JOIN wege' // counting wege
          '   ON gipfel.gipfel_ID = wege.gipfelid'
          ' LEFT JOIN komment' // counting comments
          ' ON gipfel.gipfel_id = komment.gipfelid'
          ' WHERE gipfel.sektorid = ?'
          ' GROUP BY gipfel.gipfel_id',
          [sektorid],
        ));
  }
}
