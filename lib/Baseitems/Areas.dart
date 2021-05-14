import 'dart:async';
import 'BaseItems.dart';

class Area {
  String name;
  int subareaCount;
  Area(this.name, this.subareaCount);

  factory Area.fromSql(Map<String, Object?> sqlResult) {
    return Area(
      sqlResult['gebiet'].toString(),
      sqlResult['gebiet'].toString().length, // should be subareacount
    );
  }
}

class Areas extends BaseItems {
  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    return sqlHelper.insertAreas(
      int.parse(json['gebiet_ID']),
      json['gebiet'],
      json['land'],
      json['sprache2'],
      json['gdefaultanzeige'],
      json['schwskala'],
    );
  }

  Future<List<Map<String, Object?>>> getItems({String queryItem = ""}) async {
    return await sqlHelper.queryAreas(queryItem);
  }

  FutureOr<int> deleteItems({String queryItem = ""}) {
    return sqlHelper.deleteAreas(queryItem);
  }
}
