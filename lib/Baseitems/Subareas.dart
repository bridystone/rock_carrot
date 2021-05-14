import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';

class Subarea extends BaseItem {
  int id;
  int nr;
  String name;
  int gipfelCount;
  Subarea(this.id, this.nr, this.name, this.gipfelCount)
      : super(0, name, gipfelCount);

  factory Subarea.fromSql(Map<String, Object?> sqlResult) {
    return Subarea(
      int.parse(sqlResult['sektor_ID'].toString()),
      int.parse(sqlResult['sektornr'].toString()),
      sqlResult['sektorname_d'].toString(),
      sqlResult['sektorname_d'].toString().length, // should be Subareacount
    );
  }
}

class Subareas extends BaseItems {
  Subareas(parent) : super(parent);

  FutureOr<void> fetchFromWeb(
    String queryValue, [
    String queryKey = 'gebietid',
    String target = "teilgebiet",
  ]) async {
    await super.fetchFromWeb(target, queryKey, queryValue);
  }

  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    return sqlHelper.insertSubareas(
      int.parse(json['sektor_ID']),
      int.parse(json['gebietid']),
      int.parse(json['sektornr']),
      json['sektorname_d'],
      json['sektorname_cz'],
    );
  }

  Future<List<Map<String, Object?>>> getItems({
    String queryItemString = "",
    int queryItemInt = 0,
  }) {
    return sqlHelper.querySubareas(queryItemInt);
  }

  FutureOr<int> deleteItems({
    String queryItemString = "",
    int queryItemInt = 0,
  }) {
    return sqlHelper.deleteSubareas(queryItemInt);
  }
}
