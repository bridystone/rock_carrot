import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlAreas.dart';

class Area {
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
  int _childCount;
  Area(
    this._gebietid,
    this._gebiet,
    this._land,
    this._sprache2,
    this._gdefaultanzeige,
    this._schwskala,
    this._childCount,
  );

  // Standard Value
  String get name {
    return _gebiet;
  }

  int get areaId {
    return _gebietid;
  }

  // TODO: MOVE TO BASECLASS?
  // Child element Getter + Update functions
  String get childCount {
    // state -1 == update in progress
    if (_childCount == -1) {
      return 'updating';
    }
    if (_childCount == 0) {
      return 'N/A';
    }
    return _childCount.toString();
  }

  void updateChildCount(int newValue) {
    _childCount = newValue;
  }

  void setChildCountStatus(ChildCountStatus status) {
    if (status == ChildCountStatus.empty) _childCount = 0;
    if (status == ChildCountStatus.update_in_progress) _childCount = -1;
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

  /// sorting method Name ASC
  int sortByName(Area area_a, Area area_b) {
    return area_a.name.compareTo(area_b.name);
  }

  /// sorting method Count DESC
  int sortByChildsDesc(Area area_a, Area area_b) {
    // explicitely use private integer!
    return area_b._childCount.compareTo(area_a._childCount);
  }

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
