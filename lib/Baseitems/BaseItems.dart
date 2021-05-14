import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Database/sql.dart';

abstract class BaseItems {
  late BaseItem parent;

  BaseItems(this.parent);

  SqlYacGuideFlutter sqlHelper = SqlYacGuideFlutter();
  /*
    fetch Countries to DB
    */
  FutureOr<void> fetchFromWeb(
    String target, [
    String queryKey = "",
    String queryValue = "",
  ]) async {
    final uri = Uri(
      scheme: 'http',
      host: 'db-sandsteinklettern.gipfelbuch.de',
      path: 'json' + target + '.php',
      query: 'app=yacguide' +
          ((queryKey != "")
              ? "&$queryKey=${Uri.encodeQueryComponent(
                  queryValue,
                  encoding: latin1,
                )}"
              : ""),
    );
    print(uri.toString());
    final response = await http.get(uri);
    if ((response.statusCode == 200) &&
        response.body.isNotEmpty &&
        response.body != 'null') {
      final List<dynamic> body = json.decode(response.body);
      if (int.tryParse(queryValue) == null) {
        await deleteItems(queryItemString: queryValue);
      } else {
        await deleteItems(queryItemInt: int.parse(queryValue));
      }
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

  Future<List<Map<String, Object?>>> getItems({
    String queryItemString,
    int queryItemInt,
  });

  FutureOr<int> deleteItems({
    String queryItemString,
    int queryItemInt,
  });
}
/*
class Root extends BaseItems {
  BaseItem? parent;
  Root(this.parent) : super(parent);
  // have to be overwritten
  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    return 0;
  }

  Future<List<Map<String, Object?>>> getItems({String queryItem = ""}) {
    return Future.value();
  }

  FutureOr<int> deleteItems({String queryItem = ""}) {
    return 0;
  }
}
*/
