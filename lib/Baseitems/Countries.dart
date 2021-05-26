import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlCountries.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

/// the basic country item -> direct relation to land in database
class Country {
  // fields from the database
  String land;
  String iso3166;
  String kfz;
  int areaCount;

  /// super = Parent = Baseitem (id, name, childCount) => UI=> "name (count)"
  Country(this.land, this.iso3166, this.kfz, this.areaCount);

  /// create new countryelement from sqlResult
  // TODO: use sqlHandler Table information to get this in
  factory Country.fromSql(Map<String, Object?> sqlResult) {
    return Country(
      sqlResult.values.elementAt(0).toString(), //land
      sqlResult.values.elementAt(1).toString(), //ISO3166
      sqlResult.values.elementAt(2).toString(), //KFZ
      int.parse(sqlResult.values.elementAt(3).toString()), //childCount
    );
  }
}

class Countries with Sandstein {
  SqlHandler sqlHelper = SqlHandler();

  /// initialize list of countries empty
  List<Country> _countries = [];

  set countries(List<Country> newCountries) {
    _countries = newCountries;
    // TODO: perfomring reorder etc...
    // or rather in getter?
  }

  /// retrieve current countries - if empty, get SQL data
  List<Country> get countries {
    if (_countries.isEmpty) {
      getCountries().then((sqlCountries) => _countries = sqlCountries);
    }
    //_countries.sort();
    return _countries;
  }

  /// get Items from database and transform them into a list of items
  Future<List<Country>> getCountries() {
    final sqlResults = sqlHelper.queryCountries();
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Country.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  /// delete all data from Countries-Table
  Future<int> deleteCountriesFromDatabase() {
    return sqlHelper.deleteCountries();
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(Sandstein.countriesWebTarget);
    await deleteCountriesFromDatabase();
    return sqlHelper.insertJsonData(SqlHandler.countriesTablename, jsonData);
  }
}
