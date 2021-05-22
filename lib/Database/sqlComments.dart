import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';

extension SqlHandlerComments on SqlHandler {
  Future<List<Map<String, Object?>>> queryRouteComments(
    int wegid,
  ) {
    return database.then((db) => db.query(
          SqlHandler.commentsTablename,
          columns: SqlHandler
              .databaseTableColumns[SqlHandler.commentsTablename]!.keys
              .toList(),
          where: 'wegid = ?',
          whereArgs: [wegid],
        ));
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
