import 'dart:async';
import 'package:rock_carrot/Baseitems/BaseItems.dart';
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlRocks.dart';

class Rock extends BaseItem {
  int _gipfelId;
  // ignore: unused_field
  String _gipfelNr;
  String _gipfelName;
  String _gipfelNameCZ;
  // ignore: unused_field
  String _gipfelStatus;
  // ignore: unused_field
  String _gipfelTyp;
  // ignore: unused_field
  String _vgrd;
  // ignore: unused_field
  String _ngrd;
  // ignore: unused_field
  String _posfehler;
  // ignore: unused_field
  String _schartenhoehe;
  // ignore: unused_field
  String _talhoehe;
  // ignore: unused_field
  int _sektorid;
  Rock(
    this._gipfelId,
    this._gipfelNr,
    this._gipfelName,
    this._gipfelNameCZ,
    this._gipfelStatus,
    this._gipfelTyp,
    this._vgrd,
    this._ngrd,
    this._posfehler,
    this._schartenhoehe,
    this._talhoehe,
    this._sektorid,
    int childCountInt,
    int commentCountInt,
  ) : super(
          nr: double.parse(_gipfelNr),
          childCountInt: childCountInt,
          commentCountInt: commentCountInt,
        );

  @override
  String get name {
    return (_gipfelName.isEmpty) ? _gipfelNameCZ : _gipfelName;
  }

  int get rockId {
    return _gipfelId;
  }

  factory Rock.fromSql(Map<String, Object?> sqlResult) {
    return Rock(
      int.parse(sqlResult.values.elementAt(0).toString()),
      sqlResult.values.elementAt(1).toString(),
      sqlResult.values.elementAt(2).toString(),
      sqlResult.values.elementAt(3).toString(),
      sqlResult.values.elementAt(4).toString(),
      sqlResult.values.elementAt(5).toString(),
      sqlResult.values.elementAt(6).toString(),
      sqlResult.values.elementAt(7).toString(),
      sqlResult.values.elementAt(8).toString(),
      sqlResult.values.elementAt(9).toString(),
      sqlResult.values.elementAt(10).toString(),
      int.parse(sqlResult.values.elementAt(11).toString()),
      int.parse(sqlResult.values.elementAt(12).toString()), // routes count
      int.parse(sqlResult.values.elementAt(13).toString()), // comment count
    );
  }
}

class Rocks {
  /// store parent area
  Subarea parentSubArea;
  Rocks(this.parentSubArea);

  Future<List<Rock>> getRocks() async {
    final sqlResults = SqlHandler().queryRocks(parentSubArea.subareaId);
    // maps sqlResults to Rock and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Rock.fromSql(sqlRow),
          )
          .toList(),
    );
  }
}
