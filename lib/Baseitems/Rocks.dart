import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlRocks.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Rock extends BaseItem {
  int gipfelId;
  String gipfelNr;
  String gipfelName;
  String gipfelNameCZ;
  String gipfelStatus;
  String gipfelTyp;
  String vgrd;
  String ngrd;
  String posfehler;
  String schartenhoehe;
  String talhoehe;
  int sektorid;
  int routeCount;
  Rock(
    this.gipfelId,
    this.gipfelNr,
    this.gipfelName,
    this.gipfelNameCZ,
    this.gipfelStatus,
    this.gipfelTyp,
    this.vgrd,
    this.ngrd,
    this.posfehler,
    this.schartenhoehe,
    this.talhoehe,
    this.sektorid,
    this.routeCount,
  ) : super(sektorid, gipfelName, routeCount);

  factory Rock.fromSql(Map<String, Object?> sqlResult) {
    return Rock(
      int.parse(sqlResult.values.elementAt(0).toString()),
      sqlResult.values.elementAt(1).toString(),
      sqlResult.values.elementAt(2).toString(),
      sqlResult.values.elementAt(3).toString(),
      sqlResult.values.elementAt(4).toString(),
      sqlResult.values.elementAt(5).toString(),
      sqlResult.values.elementAt(6).toString(),
      sqlResult.values.elementAt(7).toString(),
      sqlResult.values.elementAt(8).toString(),
      sqlResult.values.elementAt(9).toString(),
      sqlResult.values.elementAt(10).toString(),
      int.parse(sqlResult.values.elementAt(11).toString()),
      int.parse(sqlResult.values.elementAt(12).toString()),
    );
  }

  /// this is used this delete/insert Routes/Comments
  /// since only sektorid is important and this is not a real parent
  factory Rock.dummyRock(int sektorId) {
    return Rock(0, '', '', BaseItems.dummyName, '', '', '', '', '', '', '',
        sektorId, 0);
  }
}

class Rocks extends BaseItems with Sandstein {
  Rocks(Subarea parent) : super(parent);

  @override
  Future<List<Rock>> getItems() async {
    final sqlResults = sqlHelper.queryRocks(parent.id);
    // maps sqlResults to Rock and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Rock.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  Future<int> deleteItems() {
    // delete Routes as well with a dummy Rock Items
    return sqlHelper.deleteRocksIncludingSubitems(parent.id);
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.rocksWebTarget,
      Sandstein.rocksWebQuery,
      parent.id.toString(),
    );
    await deleteItems();
    return sqlHelper.insertJsonData(SqlHandler.rocksTablename, jsonData);
  }
}
