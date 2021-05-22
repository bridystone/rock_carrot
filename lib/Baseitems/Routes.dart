import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Database/sql.dart';
import 'package:yacguide_flutter/Database/sqlRoutes.dart';
import 'package:yacguide_flutter/Database/sqlComments.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';

class Route extends BaseItem {
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
  ) : super(gipfelId, wegname, routeCount);

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

class Routes extends BaseItems with Sandstein {
  final Rock _parentRock;
  Routes(this._parentRock) : super(_parentRock);

  @override
  Future<List<Route>> getItems() async {
    final sqlResults = sqlHelper.queryRoutes(_parentRock.gipfelId);
    // maps sqlResults to Route and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Route.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  /// get Comment data from SQLite
  Future<List<Comment>> getComments(Route route) {
    final sqlResults = sqlHelper.queryRouteComments(route.wegId);
    // maps sqlResults to Comment and return
    return sqlResults.then(
      (sqlResultsFinal) => sqlResultsFinal
          .map(
            (sqlRow) => Comment.fromSql(sqlRow),
          )
          .toList(),
    );
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateData() async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.routesWebTarget,
      Sandstein.routesWebQuery,
      parent.id.toString(),
    );
    // should have been deleted by relevant Parent
    // await deleteItems();

    return sqlHelper.insertJsonData(SqlHandler.routesTablename, jsonData);
  }
}
