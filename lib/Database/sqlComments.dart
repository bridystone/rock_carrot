import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Database/sql.dart';

extension SqlHandlerComments on SqlHandler {
  FutureOr<int> deleteComments(int sektorid) {
    return database.then(
      (db) => db.delete(
        SqlHandler.commentsTablename,
        where: 'sektorid = ?',
        whereArgs: [sektorid],
      ),
    );
  }

  Future<List<Comment>> queryRouteComments(
    int wegid,
  ) async {
    final sqlResults = await database.then((db) => db.query(
          SqlHandler.commentsTablename,
          columns: SqlHandler.databaseTableColumns['komment']!
              .map((tableRow) => tableRow['name']!)
              .toList(),
          where: 'wegid = ?',
          whereArgs: [wegid],
        ));
    return sqlResults
        .map(
          (sqlRow) => Comment.fromSql(sqlRow),
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> queryComment(
    int sektorid,
    int gipfelid,
    int wegid,
  ) {
    return database.then((db) => db.query(
          SqlHandler.commentsTablename,
          columns: [
            'komment_ID',
            'userid',
            'datum',
            'adatum',
            'wegid',
            'sektorid',
            'gebietid',
            'qual',
            'sicher',
            'nass',
            'kommentar',
            'gipfelid',
            'schwer',
            'geklettert',
            'begehung'
          ],
          where: 'sektorid = ? OR gipfelid = ? OR wegid = ?',
          whereArgs: [sektorid, gipfelid, wegid],
        ));
  }
}
