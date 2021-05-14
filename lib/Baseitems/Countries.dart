import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';

class Country extends BaseItem {
  String name;
  int areaCount;
  Country(this.name, this.areaCount) : super(0, name, 0);

  factory Country.fromSql(Map<String, Object?> sqlResult) {
    return Country(
      sqlResult['land'].toString(),
      sqlResult['land'].toString().length, // should be areacount
    );
  }
}

class Countries extends BaseItems {
  Countries(parent) : super(parent);

  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    return sqlHelper.insertCountry(
      json['land'],
      json['ISO3166'],
      json['KFZ'],
    );
  }

  FutureOr<void> fetchFromWeb([
    String queryValue = "",
    String queryKey = '',
    String target = "land",
  ]) async {
    await super.fetchFromWeb(target, queryKey, queryValue);
  }

  Future<List<Map<String, Object?>>> getItems({
    String queryItemString = "",
    int queryItemInt = 0,
  }) {
    return sqlHelper.queryCountries();
  }

  FutureOr<int> deleteItems({
    String queryItemString = "",
    int queryItemInt = 0,
  }) {
    return sqlHelper.deleteCountries();
  }
}
