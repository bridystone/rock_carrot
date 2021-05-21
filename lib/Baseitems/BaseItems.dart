import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/Routes.dart';
import 'package:yacguide_flutter/Database/sql.dart';

abstract class BaseItems {
  BaseItem parent;
  BaseItems(this.parent);

  /// list of elements in this Object
  List<BaseItem> elements = [];

  /// this name is used for checking if this is a legitimate delete/insert for Routes/Comments
  static const dummyName = '__DUMMY__NAME__';

//TODO: DON'T Do this
  static const webTargetQueries = {
    'Countries': {'target': 'land', 'query': ''},
    'Areas': {'target': 'gebiet', 'query': 'land'},
    'Subareas': {'target': 'teilgebiet', 'query': 'gebietid'},
    'Rocks': {'target': 'gipfel', 'query': 'sektorid'},
    'Routes': {'target': 'wege', 'query': 'sektorid'},
    'Comments': {'target': 'komment', 'query': 'sektorid'},
  };

  SqlHandler sqlHelper = SqlHandler();

  // TODO: GET RID OF THIS -> USE Sandstein.dart stuff
  /// fetch data via http request from db-sandsteinklettern
  ///
  /// generates URL from json+[target]+.php with the querystring
  /// webTargetqueries{[target]} ?=[queryValue]
  FutureOr<void> fetchFromWeb() async {
    // get query Value from parent item
    var queryValue = '';
    switch (runtimeType.toString()) {
      case 'Countries':
        queryValue = '';
        break;
      case 'Areas':
        queryValue = parent.name;
        break;
      default:
        queryValue = parent.id.toString();
    }
    // identify target and queryKey based on the runtime Class
    final target = webTargetQueries[runtimeType.toString()]!['target']!;
    final queryKey = webTargetQueries[runtimeType.toString()]!['query']!;

    await _fetchFromWebSingle(target, queryKey, queryValue);
  }

  FutureOr<void> _fetchFromWebSingle(
    String target,
    String queryKey,
    String queryValue,
  ) async {
    // build URI
    final uri = Uri(
      scheme: 'http',
      host: 'db-sandsteinklettern.gipfelbuch.de',
      path: 'json' + target + '.php',
      query: 'app=yacguide' +
          ((queryKey == '')
              ? ''
              : '&$queryKey=${Uri.encodeQueryComponent(
                  queryValue,
                  encoding: latin1,
                )}'),
    );
    print(uri.toString());
    final response = await http.get(uri);
    // check if response is valid and refresh items in database
    if (_isResponseValid(response)) {
      // TODO: is here a duplicate delete?!?!
      // this might be, because fetchWeb is called multi times - and every time old data is removed
      // delete should happen elsewhere
      //await deleteItems();

      // insert data to DB
      final List<dynamic> jsonData = json.decode(response.body);
      jsonData.forEach((dynamic element) {
        sqlFromJson(element);
      });
    } else {
      throw Exception('failed this receice data');
    }
  }

  bool _isResponseValid(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Empty data container' + response.request.toString());
    }
    if (response.body == 'null') {
      throw Exception('null container' + response.request.toString());
    }
    if (response.statusCode != 200) {
      throw Exception('wrong status code: ${response.statusCode}' +
          response.request.toString());
    }
    return true;
  }

  /// inserts data into database table based on the runtime type of the calling object
  ///
  /// constant array in sql Handler is used
  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    final tablename =
        SqlHandler.databaseRuntimetypeTables[runtimeType.toString()];
    // special for Routes -> add 'sektorid' to table
    // this is missing, when i want to update the tables from Rock-Fetch
    if (this is Routes) {
      json['sektorid'] = parent.id;
    }
    return sqlHelper.insertDataFromJson(
      tablename ?? 'NO_VALID_TABLE_VS_RUNTIMETYPE',
      json,
    );
  }

  /// get the items from the database
  Future<List<BaseItem>> getItems();

  FutureOr<int> deleteItems();
}
