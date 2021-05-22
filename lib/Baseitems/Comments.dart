/*
Gebiet:
http://db-sandsteinklettern.gipfelbuch.de/jsonkomment.php?app=yacguide&gebietid=29
Sektor:
http://db-sandsteinklettern.gipfelbuch.de/jsonkomment.php?app=yacguide&sektorid=95 (but also )
*/
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlComments.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Comment extends BaseItem {
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
  ) : super(-1, userid.toString(), -1);

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

class Comments extends BaseItems with Sandstein {
  Comments(BaseItem parent) : super(parent);

  @override
  Future<List<Comment>> getItems() {
    throw Exception('not to be called - should be deleted from rocks');
  }

  @override
  FutureOr<int> deleteItems() {
    if (parent.name == BaseItems.dummyName) {
      return sqlHelper.deleteComments(parent.id); // should be sektor_id
    }
    throw Exception('not to be called - should be deleted from rocks');
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.commentsWebTarget,
      Sandstein.commentsWebQuery,
      parent.id.toString(),
    );
    await deleteItems();

    return sqlHelper.insertJsonData(SqlHandler.commentsTablename, jsonData);
  }
}
