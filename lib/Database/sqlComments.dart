import 'dart:async';
import 'package:rock_carrot/Database/sql.dart';

extension SqlHandlerComments on SqlHandler {
  /// fetch Route Comments from Database
  Future<List<Map<String, Object?>>> queryRouteComments(
    int wegid,
  ) {
    return database.then((db) => db.query(
          SqlHandler.commentsTablename,
          where: 'wegid = ?',
          whereArgs: [wegid],
        ));
  }

  /// fetch Rock Comments from Database
  Future<List<Map<String, Object?>>> queryRockComments(
    int rockId,
  ) {
    return database.then((db) => db.query(
          SqlHandler.commentsTablename,
          where: 'gipfelid = ?',
          whereArgs: [rockId],
        ));
  }

  /// fetch Subarea Comments from Database
  Future<List<Map<String, Object?>>> querySubareaComments(
    int subareaId,
  ) {
    return database.then((db) => db.query(
          SqlHandler.commentsTablename,
          where: 'sektorid = ?',
          whereArgs: [subareaId],
        ));
  }

  /// fetch Subarea Comments from Database
  Future<List<Map<String, Object?>>> queryAreaComments(
    int areaId,
  ) {
    return database.then((db) => db.query(
          SqlHandler.commentsTablename,
          where: 'gebietid = ? AND wegid = 0 AND gipfelid = 0 AND sektorid = 0',
          whereArgs: [areaId],
        ));
  }
}
