import 'dart:async';
import 'package:rock_carrot/Database/sql.dart';

extension SqlHandlerTeufelsturm on SqlHandler {
  /// deletes all TT Rocks from the database
  Future<int> deleteTTRocks(int areaId) {
    return database.then((db) => db.delete(
          SqlHandler.ttRocksTablename,
          where: 'areaid = ?',
          whereArgs: [areaId],
        ));
  }

  /// deletes all TT Routes from the database
  Future<int> deleteTTRoutesbyArea(int areaId) async {
    return await database.then((db) async => await db.delete(
          SqlHandler.ttRoutesTablename,
          where: 'areaid = ?',
          whereArgs: [areaId],
        ));
  }

  /// deletes all TT Routes from the database
  Future<int> deleteTTCommentsbyArea(int areaId) async {
    return await database.then((db) async => await db.delete(
          SqlHandler.ttCommentsTablename,
          where: 'areaid = ?',
          whereArgs: [areaId],
        ));
  }

  /// retrieve all Rock ids from the database
  Future<List<Map<String, Object?>>> queryRockIdsByArea(int areaId) {
    return database.then((db) => db.query(
          SqlHandler.ttRocksTablename,
          columns: ['id'],
          where: 'areaId = ?',
          whereArgs: [areaId],
        ));
  }

  /// retrieve all Route id from the database
  Future<List<Map<String, Object?>>> queryRouteIdsByArea(int areaId) {
    return database.then((db) => db.query(
          SqlHandler.ttRoutesTablename,
          columns: [
            'id',
            'rockid',
          ],
          where: 'areaId = ?',
          whereArgs: [areaId],
        ));
  }

  ///
  Future<List<Map<String, Object?>>> queryCommentsByArea(int areaId) {
    return database.then((db) => db.query(
          SqlHandler.ttCommentsTablename,
          columns: ['id'],
          where: 'areaId = ?',
          whereArgs: [areaId],
        ));
  }

  Future<List<Map<String, Object?>>> queryCommentsCountByArea(int areaId) {
    return database.then((db) => db.rawQuery(
          'SELECT COUNT(*) '
          ' FROM ${SqlHandler.ttCommentsTablename}'
          ' WHERE areaId = ?'
          ' GROUP BY areaId',
          [areaId],
        ));
  }

  /// perform caching to TT to Sandstein mapping views to tables
  ///
  /// needs to be called after Scraping was done
  Future<void> cacheTTMapping(int areaid) async {
    return database.then((db) {
      final batch = db.batch();
      batch.delete(
        SqlHandler.ttMappingRocksTablename,
        where: 'tt_areaid = ?',
        whereArgs: [areaid],
      );
      batch.execute(
        '''
        INSERT INTO tt_mapping_rocks
          SELECT 
            tt_rocks.id as tt_rockid, 
            gipfel.gipfel_id as sandstein_rockid,
            ?
          FROM tt_rocks
            INNER JOIN tt_mapping_areas -- or tt_mapping_areas_view
            ON tt_areaid = tt_rocks.areaid AND tt_areaid = ?
            INNER JOIN gipfel
            ON sandstein_areaid = sektorid
            LEFT JOIN tt_mapping_rocks_static
            ON gipfel.gipfelname_d = tt_mapping_rocks_static.sandstein_rockname 
          WHERE name = gipfelname_d OR name = tt_rockname
        ''',
        [areaid, areaid],
      );
      batch.delete(
        SqlHandler.ttMappingRoutesTablename,
        where: 'tt_areaid = ?',
        whereArgs: [areaid],
      );
      batch.execute(
        '''
        INSERT INTO tt_mapping_routes
          SELECT 
            id as tt_routeid, 
            weg_id as sandstein_routeid,
            ?
          FROM "tt_routes"
            INNER JOIN tt_mapping_rocks -- or tt_mapping_rocks_view
            ON tt_rockid = rockid AND tt_areaid = ?
            INNER JOIN wege
            ON sandstein_rockid = gipfelid
            LEFT JOIN tt_mapping_routes_static
            ON REPLACE(wege.wegname_d,'*','') = tt_mapping_routes_static.sandstein_routename
              WHERE 
              REPLACE(
              REPLACE(
                name 
              ,'-','')
              ,' ','')
              = 
              REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    wegname_d,
                  '*',''),
                'ss','ß') -- sometimes replaced - but not always
              ,'-','')
              ,' ','')
                collate nocase 
              OR
              name = 
                REPLACE(
                  wegname_d,
                '*','')collate nocase -- sometimes ß replaced - but not always
              OR 
              name = tt_mapping_routes_static.tt_routename collate nocase
              GROUP BY id
        ''',
        [areaid, areaid],
      );
      return batch.commit();
    });
  }
}
