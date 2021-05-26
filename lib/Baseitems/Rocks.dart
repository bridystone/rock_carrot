import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlRocks.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Rock {
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
  );

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
/*
  /// this is used this delete/insert Routes/Comments
  /// since only sektorid is important and this is not a real parent
  factory Rock.dummyRock(int sektorId) {
    return Rock(0, '', '', BaseItems.dummyName, '', '', '', '', '', '', '',
        sektorId, 0);
  }
  */
}

class Rocks with Sandstein {
  SqlHandler sqlHelper = SqlHandler();

  /// store parent area
  Subarea parentSubArea;
  Rocks(this.parentSubArea);

  /// initialize list of areas empty
  List<Rock> _rocks = [];

  set rocks(List<Rock> newRocks) {
    _rocks = newRocks;
    // TODO: perfomring reorder etc...
    // or rather in getter?
  }

  /// retrieve current areas - if empty, get SQL data
  List<Rock> get rocks {
    if (_rocks.isEmpty) {
      getRocks().then((sqlRocks) => _rocks = sqlRocks);
    }
    return _rocks;
  }

  Future<List<Rock>> getRocks() async {
    final sqlResults = sqlHelper.queryRocks(parentSubArea.sektorid);
    // maps sqlResults to Rock and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Rock.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  Future<int> deleteRocksFromDatabase() {
    // delete Routes as well with a dummy Rock Items
    return sqlHelper.deleteRocksIncludingSubitems(parentSubArea.sektorid);
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.rocksWebTarget,
      Sandstein.rocksWebQuery,
      parentSubArea.sektorid.toString(),
    );
    await deleteRocksFromDatabase();
    return sqlHelper.insertJsonData(SqlHandler.rocksTablename, jsonData);
  }
}
