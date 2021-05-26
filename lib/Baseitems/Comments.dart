import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlComments.dart';

class Comment {
  int kommentId;
  int userid;
  String datum;
  String adatum;
  int wegid;
  int sektorid;
  int gebietid;
  String qual;
  String sicher;
  String nass;
  String kommentar;
  int gipfelid;
  String schwer;
  String geklettert;
  String begehung;
  Comment(
    this.kommentId,
    this.userid,
    this.datum,
    this.adatum,
    this.wegid,
    this.sektorid,
    this.gebietid,
    this.qual,
    this.sicher,
    this.nass,
    this.kommentar,
    this.gipfelid,
    this.schwer,
    this.geklettert,
    this.begehung,
  );

  factory Comment.fromSql(Map<String, Object?> sqlResult) {
    return Comment(
      int.parse(sqlResult.values.elementAt(0).toString()),
      int.parse(sqlResult.values.elementAt(1).toString()),
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
    final sqlResults = SqlHandler().queryRouteComments(routeId);
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
