import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';

extension SqlHandlerCountries on SqlHandler {
  /// deletes all countries from the database
  Future<int> deleteCountries() {
    return database.then((db) => db.delete(SqlHandler.countriesTablename));
  }

  /// retrieve all Countries from the database
  Future<List<Map<String, Object?>>> queryCountries() {
    return database.then((db) => db.rawQuery(
          'SELECT land.land, land.iso3166, land.kfz, COUNT(gebiet) as count'
          ' FROM land'
          ' LEFT OUTER JOIN gebiet'
          ' ON land.land = gebiet.land'
          ' GROUP BY land.land',
        ));
  }
}
