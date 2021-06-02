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

  Future<List<Map<String, Object?>>> queryRouteCommentsInclTT(
    int wegid,
  ) {
    return database.then((db) => db.rawQuery(
          '''
          SELECT 
            komment_ID,
            userid,
            datum,
            adatum,
            wegid,
            sektorid,
            gebietid,
            qual,
            sicher,
            nass,
            kommentar,
            gipfelid,
            schwer,
            geklettert,
            begehung,
            'Sandstein' as source
          FROM ${SqlHandler.commentsTablename}
          WHERE wegid = ?

          UNION

          SELECT 
            ID, --komment_ID,
            user, --userid,
            date, --datum,
            '', --adatum,
            routeid, --wegid,
            areaid, --sektorid,
            -1, --gebietid,
            quality, --qual,
            '', --sicher,
            '', --nass,
            comment, --kommentar,
            rockid, --gipfelid,
            '', --schwer,
            '', --geklettert,
            '', --begehung,
            'Teufelsturm' as source
          FROM tt_comments
            INNER JOIN tt_mapping_routes
            ON tt_comments.routeid = tt_mapping_routes.tt_routeid
          WHERE tt_mapping_routes.sandstein_routeid = ?
          ''',
          [wegid, wegid],
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
