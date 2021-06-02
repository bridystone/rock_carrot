import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlComments.dart';

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
  String _geklettert;
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

  String get quality {
    return _qual;
  }

  String get safety {
    return _sicher;
  }

  String get wetness {
    return _nass;
  }

  String get difficulty {
    return _schwer;
  }

  String get climbed {
    return _geklettert;
  }

  String get climb {
    return _begehung;
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
