import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Baseitems/Routes.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Database/sqlRocks.dart';

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

class Rocks extends BaseItems {
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
  FutureOr<int> deleteItems() async {
    // delete Routes as well with a dummy Rock Items
    var _ = await Routes(Rock.dummyRock(parent.id)).deleteItems();
    _ = await Comments(Rock.dummyRock(parent.id)).deleteItems();

    return sqlHelper.deleteRocks(parent.id);
  }

  /// special overide for Rocks
  /// will as well fetch data for Routes & Comments
  @override
  FutureOr<void> fetchFromWeb() async {
    // fetch Rocks
    await super.fetchFromWeb();
    // fetch Routes
    await Routes(Rock.dummyRock(parent.id)).fetchFromWeb();
    await Comments(Rock.dummyRock(parent.id)).fetchFromWeb();
  }
}
