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
  Future<void> cacheTTMapping() async {
    return database.then((db) {
      final batch = db.batch();
      batch.delete(SqlHandler.ttMappingAreasTablename);
      batch.execute('''
        INSERT INTO tt_mapping_areas
        SELECT *
        FROM tt_mapping_areas_view;
        ''');
      batch.delete(SqlHandler.ttMappingRocksTablename);
      batch.execute('''
        INSERT INTO tt_mapping_rocks
        SELECT *
        FROM tt_mapping_rocks_view;
        ''');
      batch.delete(SqlHandler.ttMappingRoutesTablename);
      batch.execute('''
        INSERT INTO tt_mapping_routes
        SELECT *
        FROM tt_mapping_routes_view;
        ''');
      return batch.commit();
    });
  }
}
