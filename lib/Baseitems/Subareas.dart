import 'dart:async';
import 'BaseItems.dart';

class Subarea {
  int nr;
  String name;
  int gipfelCount;
  Subarea(this.nr, this.name, this.gipfelCount);

  factory Subarea.fromSql(Map<String, Object?> sqlResult) {
    return Subarea(
      int.parse(sqlResult['sektornr'].toString()),
      sqlResult['sektorname_d'].toString(),
      sqlResult['sektorname_d'].toString().length, // should be Subareacount
    );
  }
}

class Subareas extends BaseItems {
  FutureOr<int> sqlFromJson(Map<String, dynamic> json) {
    return sqlHelper.insertSubareas(
      int.parse(json['sektor_ID']),
      json['gebietid'],
      json['sektornr'],
      json['sektorname_d'],
      json['sektorname_cz'],
    );
  }

  Future<List<Map<String, Object?>>> getItems({String queryItem = ""}) async {
    return await sqlHelper.querySubareas(int.parse(queryItem));
  }

  FutureOr<int> deleteItems({String queryItem = ""}) {
    return sqlHelper.deleteSubareas(int.parse(queryItem));
  }
}
