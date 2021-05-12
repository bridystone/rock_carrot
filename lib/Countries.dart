import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sql.dart';
import 'dart:async';

class Country {
  String name;
  int areaCount;
  Country(this.name, this.areaCount);

  factory Country.fromSql(Map<String, Object?> sqlResult) {
    return Country(sqlResult['land'].toString(), 2);
  }
}

class Countries {
  SqlYacGuideFlutter sqlHelper = SqlYacGuideFlutter();
  /*
    fetch Countries to DB
    */
  FutureOr<void> fetchCountries() async {
    final response = await http.get(Uri.http(
      'db-sandsteinklettern.gipfelbuch.de',
      'jsonland.php',
      {'app': 'yacguide'},
    ));
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      await sqlHelper.deleteCountries();

      //TODO: check if other activation than .toList() is possible
      body.map((item) {
        sqlFromJson(item);
      }).toList(); //toList() -> only to activate the map
    } else {
      throw Exception('failed this receice data');
    }
  }

  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    return sqlHelper.insertCountry(
      json['land'],
      json['ISO3166'],
      json['KFZ'],
    );
  }

  Future<List<Map<String, Object?>>> getCountries() async {
    return await sqlHelper.queryCountries();
  }

  FutureOr<int> deleteCountries() {
    return sqlHelper.deleteCountries();
  }
}
