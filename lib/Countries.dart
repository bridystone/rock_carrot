import 'dart:async';
import 'BaseItems.dart';

class Country {
  String name;
  int areaCount;
  Country(this.name, this.areaCount);

  factory Country.fromSql(Map<String, Object?> sqlResult) {
    return Country(
      sqlResult['land'].toString(),
      sqlResult['land'].toString().length, // should be areacount
    );
  }
}

class Countries extends BaseItems {
  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    return sqlHelper.insertCountry(
      json['land'],
      json['ISO3166'],
      json['KFZ'],
    );
  }

  Future<List<Map<String, Object?>>> getItems({String queryItem = ""}) async {
    return await sqlHelper.queryCountries();
  }

  FutureOr<int> deleteItems({String queryItem = ""}) {
    return sqlHelper.deleteCountries();
  }
}
