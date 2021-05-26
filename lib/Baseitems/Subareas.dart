import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlSubareas.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Subarea {
  int sektorid;
  int gebietid;
  String sektornr;
  String sektornameD;
  String sektornameCZ;
  int rockCount;
  Subarea(
    this.sektorid,
    this.gebietid,
    this.sektornr,
    this.sektornameD,
    this.sektornameCZ,
    this.rockCount,
  );

  factory Subarea.fromSql(Map<String, Object?> sqlResult) {
    return Subarea(
      int.parse(sqlResult.values.elementAt(0).toString()),
      int.parse(sqlResult.values.elementAt(1).toString()),
      sqlResult.values.elementAt(2).toString(),
      sqlResult.values.elementAt(3).toString(),
      sqlResult.values.elementAt(4).toString(),
      int.parse(sqlResult.values.elementAt(5).toString()),
    );
  }
/*
  /// this is used this delete/insert Comments
  /// since only gebiet is important and this is not a real parent
  factory Subarea.dummySubarea(int gebietid) {
    return Subarea(
      gebietid,
      0,
      '',
      BaseItems.dummyName,
      '',
      0,
    );
  }
  */
}

class Subareas with Sandstein {
  SqlHandler sqlHelper = SqlHandler();

  /// store parent area
  Area parentArea;
  Subareas(this.parentArea);

  /// initialize list of areas empty
  List<Subarea> _subareas = [];

  set subareas(List<Subarea> newSubareas) {
    _subareas = newSubareas;
    // TODO: perfomring reorder etc...
    // or rather in getter?
  }

  /// retrieve current areas - if empty, get SQL data
  List<Subarea> get subareas {
    if (_subareas.isEmpty) {
      getSubareas().then((sqlSubareas) => _subareas = sqlSubareas);
    }
    return _subareas;
  }

  Future<List<Subarea>> getSubareas() async {
    final sqlResults = sqlHelper.querySubareas(parentArea.gebietid);
    // maps sqlResults to Subareas and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Subarea.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  /// delete all subareas including their comemnts
  FutureOr<int> deleteSubareasFromDatabase() {
    return sqlHelper.deleteSubareasIncludingComments(parentArea.gebietid);
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.subareasWebTarget,
      Sandstein.subareasWebQuery,
      parentArea.gebietid.toString(),
    );
    await deleteSubareasFromDatabase();
    return sqlHelper.insertJsonData(SqlHandler.subareasTablename, jsonData);
  }
}
