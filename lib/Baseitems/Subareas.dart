import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlSubareas.dart';

class Subarea extends BaseItem {
  int _sektorid;
  // ignore: unused_field
  int _gebietid;
  // ignore: unused_field
  String _sektornr;
  String _sektornameD;
  String _sektornameCZ;

  Subarea(
    this._sektorid,
    this._gebietid,
    this._sektornr,
    this._sektornameD,
    this._sektornameCZ,
    int childCountInt,
    int commentCountInt,
  ) : super(
          childCountInt: childCountInt,
          commentCountInt: commentCountInt,
        );

  @override
  String get name {
    return (_sektornameD.isEmpty) ? _sektornameCZ : _sektornameD;
  }

  int get subareaId {
    return _sektorid;
  }

  factory Subarea.fromSql(Map<String, Object?> sqlResult) {
    return Subarea(
      int.parse(sqlResult.values.elementAt(0).toString()),
      int.parse(sqlResult.values.elementAt(1).toString()),
      sqlResult.values.elementAt(2).toString(),
      sqlResult.values.elementAt(3).toString(),
      sqlResult.values.elementAt(4).toString(),
      int.parse(sqlResult.values.elementAt(5).toString()), // child count
      int.parse(sqlResult.values.elementAt(6).toString()), // comment count
    );
  }
}

class Subareas {
  /// store parent area
  Area parentArea;
  Subareas(this.parentArea);

  // TODO: something for BaseItem? with <T>?
  Future<List<Subarea>> getSubareas() async {
    final sqlResults = SqlHandler().querySubareas(parentArea.areaId);
    // maps sqlResults to Subareas and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Subarea.fromSql(sqlRow),
          )
          .toList(),
    );
  }
}
