import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sql.dart';
import 'dart:async';

class Area {
  String name;
  int subareaCount;
  Area(this.name, this.subareaCount);

  factory Area.fromSql(Map<String, Object?> sqlResult) {
    return Area(
      sqlResult['gebiet'].toString(),
      sqlResult['gebiet'].toString().length, // should be subareacount
    );
  }
}

class Areas {
  SqlYacGuideFlutter sqlHelper = SqlYacGuideFlutter();
  /*
    fetch Countries to DB
    */
  FutureOr<void> fetchAreas(String land) async {
    final response = await http.get(Uri.http(
      'db-sandsteinklettern.gipfelbuch.de',
      'jsongebiet.php',
      {
        'app': 'yacguide',
        'land': land,
      },
    ));
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      await sqlHelper.deleteAreas(land);

      //TODO: check if other activation than .toList() is possible
      body.map((item) {
        sqlFromJson(item);
      }).toList(); //toList() -> only to activate the map
    } else {
      throw Exception('failed this receice data');
    }
  }

  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    return sqlHelper.insertAreas(
      int.parse(json['gebiet_ID']),
      json['gebiet'],
      json['land'],
      json['sprache2'],
      json['gdefaultanzeige'],
      json['schwskala'],
    );
  }

  Future<List<Map<String, Object?>>> getAreas(String land) async {
    return await sqlHelper.queryAreas(land);
  }

  FutureOr<int> deleteAreas(String land) {
    return sqlHelper.deleteAreas(land);
  }
}
