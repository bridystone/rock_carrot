import 'dart:async';
import 'package:rock_carrot/Baseitems/BaseItems.dart';
import 'package:rock_carrot/Baseitems/Rocks.dart';
import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlRoutes.dart';

class Route extends BaseItem {
  int _wegId;
  // ignore: unused_field
  int _gipfelId;
  String _schwierigkeit;
  String _erstbegvorstieg;
  String _erstbegnachstieg;
  String _erstbegdatum;
  String _ringzahl;
  String _wegbeschr;
  String _wegbeschrCZ;
  String _kletterei;
  String _wegname;
  String _wegnameCZ;
  // ignore: unused_field
  String _wegstatus;
  // ignore: unused_field
  String _wegnr;
  Route(
    this._wegId,
    this._gipfelId,
    this._schwierigkeit,
    this._erstbegvorstieg,
    this._erstbegnachstieg,
    this._erstbegdatum,
    this._ringzahl,
    this._wegbeschr,
    this._wegbeschrCZ,
    this._kletterei,
    this._wegname,
    this._wegnameCZ,
    this._wegstatus,
    this._wegnr,
    int commentCountInt,
  ) : super(
          nr: double.parse(_wegnr),
          commentCountInt: commentCountInt,
        );

  @override
  String get name {
    return (_wegname.isEmpty) ? _wegnameCZ : _wegname;
  }

  /// climbing grade
  String get grade {
    return _schwierigkeit;
  }

  String get climbingStyle {
    return _kletterei.isEmpty ? '' : '[$_kletterei]';
  }

  String get rings {
    return 'Ringe: $_ringzahl';
  }

  String get description {
    return (_wegbeschr == '') ? _wegbeschrCZ : _wegbeschr;
  }

  String get firstAscentDate {
    return _erstbegdatum.substring(0, 4);
  }

  String get firstAscentLead {
    return _erstbegvorstieg;
  }

  String get firstAscentPartners {
    return _erstbegnachstieg;
  }

  int get routeId {
    return _wegId;
  }

  factory Route.fromSql(Map<String, Object?> sqlResult) {
    return Route(
      int.parse(sqlResult.values.elementAt(0).toString()),
      int.parse(sqlResult.values.elementAt(1).toString()),
      sqlResult.values.elementAt(2).toString(),
      sqlResult.values.elementAt(3).toString(),
      sqlResult.values.elementAt(4).toString(),
      sqlResult.values.elementAt(5).toString(),
      sqlResult.values.elementAt(6).toString(),
      sqlResult.values.elementAt(7).toString(),
      sqlResult.values.elementAt(8).toString(),
      sqlResult.values.elementAt(9).toString(),
      sqlResult.values.elementAt(10).toString(),
      sqlResult.values.elementAt(11).toString(),
      sqlResult.values.elementAt(12).toString(),
      sqlResult.values.elementAt(13).toString(),
      int.parse(sqlResult.values.elementAt(14).toString()), //comment count
    );
  }
}

class Routes {
  final Rock parentRock;
  Routes(this.parentRock);

  Future<List<Route>> getRoutes() async {
    final sqlResults = SqlHandler().queryRoutes(parentRock.rockId);
    // maps sqlResults to Route and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Route.fromSql(sqlRow),
          )
          .toList(),
    );
  }
}
