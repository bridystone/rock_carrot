import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:rock_carrot/Web/WebHelper.dart';

class Sandstein with WebHelper {
  static final _singleton = Sandstein._();
  Sandstein._();

  factory Sandstein() {
    return _singleton;
  }

  /// static constanst for all webQueries
  // countries
  static const countriesWebTarget = 'land';
  // areas
  static const areasWebTarget = 'gebiet';
  static const areasWebQuery = 'land';
  // subareas
  static const subareasWebTarget = 'teilgebiet';
  static const subareasWebQuery = 'gebietid';
  // rocks
  static const rocksWebTarget = 'gipfel';
  static const rocksWebQuery = 'sektorid';
  // rocks
  static const routesWebTarget = 'wege';
  static const routesWebQuery = 'sektorid';
  // comments
  static const commentsWebTarget = 'komment';
  static const commentsWebQueryRocks = 'sektorid';
  static const commentsWebQuerySubareas = 'gebietid';

  /// fetch data via http request from db-sandsteinklettern
  ///
  /// generates URL from json+[target]+.php with the querystring
  /// webTargetqueries{[target]} ?=[queryValue]
  Future<List<dynamic>> fetchJsonFromWeb(
    String target, [
    String? queryKey,
    String queryValue = '',
  ]) async {
    // build query, if given
    var query = 'app=yacguide';
    if (queryKey != null) {
      query += '&$queryKey=${Uri.encodeQueryComponent(
        queryValue,
        encoding: latin1,
      )}';
    }

    // build URI
    final uri = Uri(
      scheme: 'http',
      host: 'db-sandsteinklettern.gipfelbuch.de',
      path: 'json' + target + '.php',
      query: query,
    );

    // debugmessage only in debug mode
    if (kDebugMode) print(uri.toString());

    // making the request
    final response = await http.get(uri);
    // check if response is valid and refresh items in database
    if (isResponseValid(response)) {
      // insert data to DB
      return json.decode(_cleanString(response.body));
    } else {
      throw Exception('failed this receice data');
    }
  }

  /// clean encoding in returned strings
  String _cleanString(String _string) {
    var unesc = HtmlUnescape();
    //unescape HTML-Encoding like &#268
    var string_unesc = unesc.convert(_string);
    //replace ambigous Czech encoding to correct UTF8
    return string_unesc
        .replaceAll(r"\u008a", "\u0160")
        .replaceAll(r"\u008e", "\u017d")
        .replaceAll(r"\u009a", "\u0161")
        .replaceAll(r"\u009e", "\u017e");
  }

  /// handle bad answers from http response
  ///
  /// TODO: implement as logging
  bool _isResponseValid(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Empty data container' + response.request.toString());
    }
    // Text:'null' from json indicates, that no data is available
    if (response.body == 'null') {
      throw Exception('null container' + response.request.toString());
    }
    if (response.statusCode != 200) {
      throw Exception('wrong status code: ${response.statusCode}' +
          response.request.toString());
    }
    return true;
  }
}
