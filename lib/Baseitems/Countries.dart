import 'dart:async';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlCountries.dart';

/// the basic country item -> direct relation to land in database
enum AreaCountStatus {
  empty,
  update_in_progress,
}

class Country {
  // fields from the database
  String land;
  String iso3166;
  String kfz;
  int _areaCount;

  String get areaCount {
    // state -1 == update in progress
    if (_areaCount == -1) {
      return 'updating';
    }
    if (_areaCount == 0) {
      return 'N/A';
    }
    return _areaCount.toString();
  }

  void updateAreaCount(int newValue) {
    _areaCount = newValue;
  }

  void setAreaCountStatus(AreaCountStatus status) {
    if (status == AreaCountStatus.empty) _areaCount = 0;
    if (status == AreaCountStatus.update_in_progress) _areaCount = -1;
  }

  /// super = Parent = Baseitem (id, name, childCount) => UI=> "name (count)"
  Country(this.land, this.iso3166, this.kfz, this._areaCount);

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

class Countries {
  SqlHandler sqlHelper = SqlHandler();

  // current sorting
  int currentSort(Country c1, Country c2) => sortByChildsDesc(c1, c2);

  int sortByName(Country country_a, Country country_b) {
    return country_a.land.compareTo(country_b.land);
  }

  int sortByChildsDesc(Country country_a, Country country_b) {
    return country_b._areaCount.compareTo(country_a._areaCount);
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
}
