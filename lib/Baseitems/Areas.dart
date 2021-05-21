import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Database/sqlAreas.dart';

class Area extends BaseItem {
  @override
  int id;
  @override
  String name;
  int subareaCount;
  Area(this.id, this.name, this.subareaCount) : super(id, name, subareaCount);

  factory Area.fromSql(Map<String, Object?> sqlResult) {
    return Area(
      int.parse(sqlResult['gebiet_ID'].toString()),
      sqlResult['gebiet'].toString(),
      int.parse(sqlResult['count'].toString()), // should be subareacount
    );
  }
}

class Areas extends BaseItems {
  Areas(Country parent) : super(parent);

  @override
  Future<List<Area>> getItems() async {
    final sqlAreas = await sqlHelper.queryAreas(parent.name);
    return sqlAreas
        .map(
          (sqlResultRow) => Area.fromSql(sqlResultRow),
        )
        .toList();
  }

  @override
  FutureOr<int> deleteItems() {
    return sqlHelper.deleteAreas(parent.name);
  }
}
