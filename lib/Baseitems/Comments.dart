import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

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

class Comments with Sandstein {
  SqlHandler sqlHelper = SqlHandler();

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  ///
  // TODO: fix comments
/*
  Future<int> updateSubarea() async {
    // decision, if comments are called for Subareas (gebietid )
    // or Rocks (sektorid)
    final String queryKey;
    if (parent is Rock) {
      queryKey = Sandstein.commentsWebQueryRocks;
    } else {
      queryKey = Sandstein.commentsWebQuerySubareas;
    }
    // fetch from db-sandsteinklettern
    var jsonData = fetchJsonFromWeb(
      Sandstein.commentsWebTarget,
      queryKey,
      parent.id.toString(),
    );

    // should have been deleted by relevant Parent
    // await deleteItems();

    return sqlHelper.insertJsonData(SqlHandler.commentsTablename, jsonData);
  }
  */
}
