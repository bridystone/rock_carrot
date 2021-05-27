import 'dart:async';
import 'package:rock_carrot/Database/sql.dart';

extension SqlHandlerRoutes on SqlHandler {
  Future<List<Map<String, Object?>>> queryRoutes(
    int gipfelid,
  ) {
    return database.then((db) => db.rawQuery(
          'SELECT'
          ' wege.*,'
          ' COUNT(DISTINCT komment.komment_id) as komment_count'
          ' FROM wege'
          ' LEFT OUTER JOIN komment'
          ' ON wege.weg_id = komment.wegid'
          ' WHERE wege.gipfelid = ?'
          ' GROUP BY wegnr',
          [gipfelid],
        ));
  }
}
