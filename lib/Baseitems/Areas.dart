import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlAreas.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Area extends BaseItem {
  int gebietid;
  String gebiet;
  String land;
  String sprache2;
  String gdefaultanzeige;
  String schwskala;
  int subareaCount;
  Area(
    this.gebietid,
    this.gebiet,
    this.land,
    this.sprache2,
    this.gdefaultanzeige,
    this.schwskala,
    this.subareaCount,
  ) : super(gebietid, gebiet, subareaCount);

  factory Area.fromSql(Map<String, Object?> sqlResult) {
    return Area(
      int.parse(sqlResult.values.elementAt(0).toString()),
      sqlResult.values.elementAt(1).toString(),
      sqlResult.values.elementAt(2).toString(),
      sqlResult.values.elementAt(3).toString(),
      sqlResult.values.elementAt(4).toString(),
      sqlResult.values.elementAt(5).toString(),
      int.parse(sqlResult.values.elementAt(6).toString()),
    );
  }
}

class Areas extends BaseItems with Sandstein {
  Areas(Country parent) : super(parent);

  @override
  Future<List<Area>> getItems() async {
    final sqlResults = sqlHelper.queryAreas(parent.name);
    // maps sqlResults to Area and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Area.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  FutureOr<int> deleteItems() {
    return sqlHelper.deleteAreas(parent.name);
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.areasWebTarget,
      Sandstein.areasWebQuery,
      parent.name,
    );
    await deleteItems();
    return sqlHelper.insertJsonData(SqlHandler.areasTablename, jsonData);
  }
}
