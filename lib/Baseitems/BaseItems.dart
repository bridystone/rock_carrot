import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../Database/sql.dart';

abstract class BaseItems {
  SqlYacGuideFlutter sqlHelper = SqlYacGuideFlutter();
  /*
    fetch Countries to DB
    */
  //TODO: Sonderzeichen fukntionieren noch nicht (Türkei/Großbritanien) -> urlencode?
  FutureOr<void> fetchFromWeb(String target,
      {String queryKey = "", String queryValue = ""}) async {
    // add "secret" key :)
    final response = await http.get(Uri.http(
      'db-sandsteinklettern.gipfelbuch.de',
      'json' + target + '.php',
      {
        'app': 'yacguide',
        if (queryKey != "") queryKey: queryValue,
      },
    ));
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      await deleteItems(queryItem: queryValue);

      //TODO: check if other activation than .toList() is possible
      body.map((item) {
        sqlFromJson(item);
      }).toList(); //toList() -> only to activate the map
    } else {
      throw Exception('failed this receice data');
    }
  }

  // have to be overwritten
  FutureOr<int> sqlFromJson(Map<String, dynamic> json);

  Future<List<Map<String, Object?>>> getItems({String queryItem = ""});

  FutureOr<int> deleteItems({String queryItem = ""});
}
