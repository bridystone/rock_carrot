import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlRoutes.dart';

class Route with Comments {
  int wegId;
  int gipfelId;
  String schwierigkeit;
  String erstbegvorstieg;
  String erstbegnachstieg;
  String erstbegdatum;
  String ringzahl;
  String wegbeschr;
  String wegbeschrCZ;
  String kletterei;
  String wegname;
  String wegnameCZ;
  String wegstatus;
  String wegnr;
  int routeCount;
  Route(
    this.wegId,
    this.gipfelId,
    this.schwierigkeit,
    this.erstbegvorstieg,
    this.erstbegnachstieg,
    this.erstbegdatum,
    this.ringzahl,
    this.wegbeschr,
    this.wegbeschrCZ,
    this.kletterei,
    this.wegname,
    this.wegnameCZ,
    this.wegstatus,
    this.wegnr,
    this.routeCount,
  );

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
      int.parse(sqlResult.values.elementAt(14).toString()),
    );
  }
}

class Routes {
  SqlHandler sqlHelper = SqlHandler();

  final Rock parentRock;
  final Subarea parentSubarea;
  Routes(this.parentSubarea, this.parentRock);

  /// initialize list of areas empty
  List<Route> _routes = [];

  set routes(List<Route> newRoutes) {
    _routes = newRoutes;
    // TODO: perfomring reorder etc...
    // or rather in getter?
  }

  /// retrieve current areas - if empty, get SQL data
  List<Route> get routes {
    if (_routes.isEmpty) {
      getRoutes().then((sqlRoutes) => _routes = sqlRoutes);
    }
    return _routes;
  }

  Future<List<Route>> getRoutes() async {
    final sqlResults = sqlHelper.queryRoutes(parentRock.gipfelId);
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
