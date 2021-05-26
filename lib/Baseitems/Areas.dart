import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlAreas.dart';

class Area {
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
  );

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
  SqlHandler sqlHelper = SqlHandler();

  /// store parent country
  Country parentCountry;
  Areas(this.parentCountry);

  /// initialize list of areas empty
  List<Area> _areas = [];

  set areas(List<Area> newAreas) {
    _areas = newAreas;
    // TODO: perfomring reorder etc...
    // or rather in getter?
  }

  /// retrieve current areas - if empty, get SQL data
  List<Area> get areas {
    if (_areas.isEmpty) {
      getAreas().then((sqlAreas) => _areas = sqlAreas);
    }
    return _areas;
  }

  Future<List<Area>> getAreas() async {
    final sqlResults = sqlHelper.queryAreas(parentCountry.land);
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
