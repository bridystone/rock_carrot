import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlCountries.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

/// the basic country item -> direct relation to land in database
class Country extends BaseItem {
  // fields from the database
  String land;
  String iso3166;
  String kfz;

  /// super = Parent = Baseitem (id, name, childCount) => UI=> "name (count)"
  Country(this.land, this.iso3166, this.kfz, int childCount)
      : super(0, land, childCount);

  /// create new countryelement from sqlResult
  factory Country.fromSql(Map<String, Object?> sqlResult) {
    return Country(
      sqlResult.values.elementAt(0).toString(), //land
      sqlResult.values.elementAt(1).toString(), //ISO3166
      sqlResult.values.elementAt(2).toString(), //KFZ
      int.parse(sqlResult.values.elementAt(3).toString()), //childCount
    );
  }
}

class Countries extends BaseItems with Sandstein {
  Countries(BaseItem parent) : super(parent);

  /// get Items from database and transform them into a list of items
  @override
  Future<List<Country>> getItems() async {
    final sqlCountries = await sqlHelper.queryCountries();
    return sqlCountries
        .map((sqlResultRow) => Country.fromSql(sqlResultRow))
        .toList();
  }

  /// delete all data from Countries-Table
  @override
  Future<int> deleteItems() {
    return sqlHelper.deleteCountries();
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(Sandstein.countriesWebTarget);
    await deleteItems();
    return sqlHelper.insertJsonData(SqlHandler.countriesTablename, jsonData);
  }
}
