import 'package:flutter/material.dart';
import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlComments.dart';
import 'package:rock_carrot/artwork/DBSandsteinIcons.dart';

class Comment {
  // ignore: unused_field
  int _kommentId;
  String _userid;
  String _datum;
  // ignore: unused_field
  String _adatum;
  // ignore: unused_field
  int _wegid;
  // ignore: unused_field
  int _sektorid;
  // ignore: unused_field
  int _gebietid;
  String _qual;
  String _sicher;
  String _nass;
  String _kommentar;
  // ignore: unused_field
  int _gipfelid;
  String _schwer;
  // ignore: unused_field
  String _geklettert;
  // ignore: unused_field
  String _begehung;

  Comment(
    this._kommentId,
    this._userid,
    this._datum,
    this._adatum,
    this._wegid,
    this._sektorid,
    this._gebietid,
    this._qual,
    this._sicher,
    this._nass,
    this._kommentar,
    this._gipfelid,
    this._schwer,
    this._geklettert,
    this._begehung,
  );

  String get date {
    return _datum.substring(0, 10);
  }

  String get userId {
    return _userid.toString();
  }

  String get comment {
    return _kommentar;
  }

  bool get hasQualityRoute {
    return qualityRouteIcon != null;
  }

  IconData? get qualityRouteIcon {
    switch (_qual) {
      case '1':
      case '+++ (Herausragend)':
      case '++ (sehr gut)':
        return DBSandsteinIcons.top;
      case '2':
      case '+ (gut)':
        return DBSandsteinIcons.smile;
      case '3':
      case '(Normal)':
        return Icons.do_not_disturb_alt;
      case '4':
      case '- (schlecht)':
        return DBSandsteinIcons.wink;
      case '5':
      case '-- (sehr schlecht)':
      case '--- (Kamikaze)':
        return DBSandsteinIcons.puke;
    }
    return null;
  }

  bool get hasSafetyRoute {
    return safetyRouteIcon != null;
  }

  IconData? get safetyRouteIcon {
    switch (_sicher) {
      case '1':
        return DBSandsteinIcons.ringe;
      case '2':
        return DBSandsteinIcons.ring;
      case '3':
        return Icons.do_not_disturb_alt;
      case '4':
        return DBSandsteinIcons.ausruf;
      case '5':
        return DBSandsteinIcons.totenk;
      case '6':
        return DBSandsteinIcons.tot;
    }
    return null;
  }

  bool get hasWetnessRoute {
    return wetnessRouteIcon != null;
  }

  IconData? get wetnessRouteIcon {
    switch (_nass) {
      case '1':
        return Icons.wb_sunny;
      case '2':
        return Icons.wb_sunny_outlined;
      case '3':
        return Icons.brightness_medium;
      case '4':
        return DBSandsteinIcons.frosch;
      case '5':
        return DBSandsteinIcons.fisch;
    }
    return null;
  }

  bool get hasDiffucultyRoute {
    return difficultyRoute != null;
  }

  final difficultymap = {
    '1': 'I',
    '2': 'II',
    '3': 'III',
    '4': 'IV',
    '5': 'V',
    '6': 'VI',
    '7': 'VIIa',
    '8': 'VIIb',
    '9': 'VIIc',
    '10': 'VIIIa',
    '11': 'VIIIb',
    '12': 'VIIIc',
    '13': 'IXa',
    '14': 'IXb',
    '15': 'IXc',
    '16': 'Xa',
    '17': 'Xb',
    '18': 'Xc',
  };

  String? get difficultyRoute {
    return difficultymap[_schwer];
  }

  factory Comment.fromSql(Map<String, Object?> sqlResult) {
    return Comment(
      int.parse(sqlResult.values.elementAt(0).toString()),
      sqlResult.values.elementAt(1).toString(),
      sqlResult.values.elementAt(2).toString(),
      sqlResult.values.elementAt(3).toString(),
      int.parse(sqlResult.values.elementAt(4).toString()),
      int.parse(sqlResult.values.elementAt(5).toString()),
      int.parse(sqlResult.values.elementAt(6).toString()),
      sqlResult.values.elementAt(7).toString(),
      sqlResult.values.elementAt(8).toString(),
      sqlResult.values.elementAt(9).toString(),
      sqlResult.values.elementAt(10).toString(),
      int.parse(sqlResult.values.elementAt(11).toString()),
      sqlResult.values.elementAt(12).toString(),
      sqlResult.values.elementAt(13).toString(),
      sqlResult.values.elementAt(14).toString(),
    );
  }
}

class Comments {
  /// get all Area comments from database and transfer them to object list
  Future<List<Comment>> getAreaComments(int areaId) async {
    final sqlResults = SqlHandler().queryAreaComments(areaId);
    // maps sqlResults to Rock and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Comment.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  /// get all Subarea comments from database and transfer them to object list
  Future<List<Comment>> getSubareaComments(int subareaId) async {
    final sqlResults = SqlHandler().querySubareaComments(subareaId);
    // maps sqlResults to Rock and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Comment.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  /// get all Rock comments from database and transfer them to object list
  Future<List<Comment>> getRockComments(int rockId) async {
    final sqlResults = SqlHandler().queryRockComments(rockId);
    // maps sqlResults to Rock and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Comment.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  /// get all Route comments from database and transfer them to object list
  Future<List<Comment>> getRouteComments(int routeId) async {
    final sqlResults = SqlHandler().queryRouteCommentsInclTT(routeId);
    // maps sqlResults to Rock and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Comment.fromSql(sqlRow),
          )
          .toList(),
    );
  }
}
