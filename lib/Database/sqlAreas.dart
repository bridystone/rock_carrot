import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';

extension SqlHandlerAreas on SqlHandler {
  FutureOr<int> deleteAreas(String land) {
    return database.then(
      (db) => db.delete(
        SqlHandler.areasTablename,
        where: 'land = ?',
        whereArgs: [land],
      ),
    );
  }

  Future<List<Map<String, Object?>>> queryAreas(String land) {
    return database.then((db) => db.rawQuery(
          'SELECT'
          ' gebiet.*,'
          ' COUNT(DISTINCT teilgebiet.sektor_id) as subarea_count,'
          ' COUNT(DISTINCT komment.komment_id) as komment_count'
          ' FROM gebiet'
          ' LEFT OUTER JOIN teilgebiet' // counting subareas
          ' ON gebiet.gebiet_ID = teilgebiet.gebietid'
          ' LEFT JOIN komment' // counting comments
          ' ON gebiet.gebiet_ID = komment.gebietid'
          ' WHERE gebiet.land = ?'
          ' GROUP BY gebiet.gebiet_ID',
          [land],
        ));
  }
}
