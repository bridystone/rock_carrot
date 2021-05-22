import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Baseitems/Routes.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlRocks.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Rock extends BaseItem {
  @override
  int id; /*sektorid!!*/
  int gipfelId;
  String gipfelNr;
  String gipfelName;
  String gipfelNameCZ;
  String gipfelStatus;
  String gipfelTyp;
  String schartenhoehe;
  String talhoehe;
  int routeCount;
  Rock(
    this.id,
    this.gipfelId,
    this.gipfelNr,
    this.gipfelName,
    this.gipfelNameCZ,
    this.gipfelStatus,
    this.gipfelTyp,
    this.schartenhoehe,
    this.talhoehe,
    this.routeCount,
  ) : super(id, gipfelName, routeCount);

  factory Rock.fromSql(Map<String, Object?> sqlResult) {
    return Rock(
      int.parse(sqlResult['sektorid'].toString()),
      int.parse(sqlResult['gipfel_ID'].toString()),
      sqlResult['gipfelnr'].toString(),
      sqlResult['gipfelname_d'].toString(),
      sqlResult['gipfelname_cz'].toString(),
      sqlResult['status'].toString(),
      sqlResult['typ'].toString(),
      sqlResult['schartenhoehe'].toString(),
      sqlResult['talhoehe'].toString(),
      int.parse(sqlResult['count'].toString()), // should be Subareacount
    );
  }

  /// this is used this delete/insert Routes/Comments
  /// since only sektorid is important and this is not a real parent
  factory Rock.dummyRock(int sektorId) {
    return Rock(sektorId, 0, '', BaseItems.dummyName, '', '', '', '', '', 0);
  }
}

class Rocks extends BaseItems with Sandstein {
  Rocks(Subarea parent) : super(parent);

  @override
  Future<List<Rock>> getItems() async {
    final sqlRocks = await sqlHelper.queryRocks(parent.id);
    return sqlRocks
        .map(
          (sqlResultRow) => Rock.fromSql(sqlResultRow),
        )
        .toList();
  }

  @override
  FutureOr<int> deleteItems() {
    // delete Routes as well with a dummy Rock Items
    var _ = Routes(Rock.dummyRock(parent.id)).deleteItems();
    _ = Comments(Rock.dummyRock(parent.id)).deleteItems();

    return sqlHelper.deleteRocks(parent.id);
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
