import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlSubareas.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Subarea extends BaseItem {
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
  ) : super(sektorid, sektornameD, rockCount); //parent information

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
}

class Subareas extends BaseItems with Sandstein {
  Subareas(Area parent) : super(parent);

  @override
  Future<List<Subarea>> getItems() async {
    final sqlResults = sqlHelper.querySubareas(parent.id);
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
  FutureOr<int> deleteItems() {
    return sqlHelper.deleteSubareasIncludingComments(parent.id);
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.subareasWebTarget,
      Sandstein.subareasWebQuery,
      parent.id.toString(),
    );
    await deleteItems();
    return sqlHelper.insertJsonData(SqlHandler.subareasTablename, jsonData);
  }
}
