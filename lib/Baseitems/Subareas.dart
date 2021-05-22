import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlSubareas.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Subarea extends BaseItem {
  @override
  int id;
  int nr;
  @override
  String name;
  int rockCount;
  Subarea(this.id, this.nr, this.name, this.rockCount)
      : super(id, name, rockCount);

  factory Subarea.fromSql(Map<String, Object?> sqlResult) {
    return Subarea(
      int.parse(sqlResult['sektor_ID'].toString()),
      int.parse(sqlResult['sektornr'].toString()),
      sqlResult['sektorname_d'].toString(),
      int.parse(sqlResult['count'].toString()), // should be Subareacount
    );
  }
}

class Subareas extends BaseItems with Sandstein {
  Subareas(Area parent) : super(parent);

  @override
  Future<List<Subarea>> getItems() async {
    final sqlSubareas = await sqlHelper.querySubareas(parent.id);
    return sqlSubareas
        .map(
          (sqlResultRow) => Subarea.fromSql(sqlResultRow),
        )
        .toList();
  }

  @override
  FutureOr<int> deleteItems() {
    return sqlHelper.deleteSubareas(parent.id);
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
