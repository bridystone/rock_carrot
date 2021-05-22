import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';

extension SqlHandlerRoutes on SqlHandler {
  Future<List<Map<String, Object?>>> queryRoutes(
    int gipfelid,
  ) {
    return database.then((db) => db.query(
          SqlHandler.routesTablename,
          columns: [
            'sektorid',
            'Weg_ID',
            'gipfelid',
            'schwierigkeit',
            'erstbegvorstieg',
            'erstbegnachstieg',
            'erstbegdatum',
            'ringzahl',
            'wegbeschr_d',
            'wegbeschr_cz',
            'kletterei',
            'wegname_d',
            'wegname_cz',
            'wegstatus',
            'wegnr'
          ],
          where: 'gipfelid = ?',
          whereArgs: [gipfelid],
          orderBy: 'wegnr',
        ));
  }
}
