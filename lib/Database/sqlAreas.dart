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
          'SELECT gebiet.*, COUNT(teilgebiet.gebietid) as count'
          ' FROM gebiet'
          ' LEFT OUTER JOIN teilgebiet'
          ' ON gebiet.gebiet_ID = teilgebiet.gebietid'
          ' WHERE land = ?'
          ' GROUP BY gebiet.gebiet_ID',
          [land],
        ));
  }
}
