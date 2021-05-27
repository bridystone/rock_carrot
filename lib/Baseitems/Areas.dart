import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlAreas.dart';

class Area extends BaseItem {
  int _gebietid;
  String _gebiet;
  // ignore: unused_field
  String _land;
  // ignore: unused_field
  String _sprache2;
  // ignore: unused_field
  String _gdefaultanzeige;
  // ignore: unused_field
  String _schwskala;
  Area(
    this._gebietid,
    this._gebiet,
    this._land,
    this._sprache2,
    this._gdefaultanzeige,
    this._schwskala,
    int childCountInt,
  ) : super(childCountInt: childCountInt);

  // Standard Value
  @override
  String get name {
    return _gebiet;
  }

  int get areaId {
    return _gebietid;
  }

  // SQL data to Object
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

class Areas {
  /// store parent country
  Country parentCountry;
  Areas(this.parentCountry);

  Future<List<Area>> getAreas() async {
    final sqlResults = SqlHandler().queryAreas(parentCountry.name);
    // maps sqlResults to Area and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Area.fromSql(sqlRow),
          )
          .toList(),
    );
  }
}
