import 'package:flutter/foundation.dart';
import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlTeufelsturm.dart';
import 'package:rock_carrot/Web/Teufelsturm.dart';
import 'package:rock_carrot/dev/performance.dart';

extension TeufelsturmSql on Teufelsturm {
  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateTTComments(int areaId) async {
    // get Rocks of Areas ID;
    var perf = Performance();
    perf.start('rocks');
    perf.start('fetch');
    // TODO: DISABLE CACHING
    final rockResponse = (await caching('rock', areaId, fetchRocksByArea))!;
    // final rockResponse = await fetchRocksByArea(areaId);
    perf.stop('fetch');
    perf.start('parse');
    final jsonData = parseRocks(rockResponse, areaId: areaId);
    perf.stop('parse');
    perf.start('delete');
    await SqlHandler().deleteTTRocks(areaId);
    perf.stop('delete');
    perf.start('insert');
    final rockCount = SqlHandler().insertJsonData(
      SqlHandler.ttRocksTablename,
      jsonData,
    );
    perf.stop('insert');
    perf.stop('rocks');
    perf.printAnalysis('ROCKS');

/*
    // get all Routes by AreaID
    final routesResponse = await fetchRoutesByArea(areaId);
    final jsonRoutes = parseRoutes(routesResponse, areaId: areaId);
    await SqlHandler().deleteTTRoutesbyArea(areaId);
    final routesCount = await SqlHandler().insertJsonData(
      SqlHandler.ttRoutesTablename,
      jsonRoutes,
    );
*/
    perf = Performance();
    // get all Routes by RockID
    // remove old Routes
    perf.start('routes');
    await SqlHandler().deleteTTRoutesbyArea(areaId);
    // iterate through all Rocks and receive routes
    final sqlRockIds = await SqlHandler().queryRockIdsByArea(areaId);
    final batchRoutes = await SqlHandler().prepareInsertJsonData();
    for (var sqlRockId in sqlRockIds.toList()) {
      final rockId = int.tryParse(sqlRockId.values.elementAt(0).toString());
      //perform number of retries
      String? routeResponse;
      var retries = 5;
      perf.start('fetch');
      // TODO: DISABLE CACHING
      while ((routeResponse =
              await caching('route', rockId ?? 0, fetchRoutesByRock)) ==
          null) {
        // while ((routeResponse = await fetchRoutesByRock(rockId ?? 0)) == null) {
        if (--retries <= 0) {
          print('TOO MUCH RETRIES for areaId $areaId');
          break;
        }
      }
      perf.stop('fetch');
      perf.start('parse');
      final jsonRoutes = parseRoutesRegEx(
        routeResponse ?? '',
        rockId: rockId ?? -1,
        areaId: areaId,
      );
      perf.stop('parse');
      perf.start('enque');
      final routesCount = SqlHandler().enqueueInsertJsonData(
        batchRoutes,
        SqlHandler.ttRoutesTablename,
        jsonRoutes,
      );
      perf.stop('enque');
    }
    await SqlHandler().commitInsertJsonData(batchRoutes);

    perf.stop('routes');
    perf.printAnalysis('ROUTES');

    perf = Performance();
    // first remove old comments
    perf.start('comments');
    perf.start('init');
    await SqlHandler().deleteTTCommentsbyArea(areaId);
    final batchComments = await SqlHandler().prepareInsertJsonData();
    var count = await SqlHandler().queryCommentsByArea(areaId);
    // iterate through all Routes and receive comments
    final sqlRoutes = await SqlHandler().queryRouteIdsByArea(areaId);
    perf.stop('init');
    for (var sqlRouteId in sqlRoutes.toList()) {
      final routeId = int.tryParse(sqlRouteId.values.elementAt(0).toString());
      final rockId = int.tryParse(sqlRouteId.values.elementAt(1).toString());

      perf.start('fetch');
      //perform number of retries
      String? commentsResponse;
      var retries = 5;
      // TODO: DISABLE CACHING
      while ((commentsResponse =
              await caching('comment', routeId ?? 0, fetchCommentsByRoute)) ==
          null) {
        // while ((commentsResponse = await fetchCommentsByRoute(routeId ?? 0)) ==
        // null) {
        if (--retries <= 0) {
          print('TOO MUCH RETRIES for areaId $areaId');
          break;
        }
      }
      perf.stop('fetch');
//      final commentsResponse = await fetchCommentsByRoute(routeId ?? 0);
      perf.start('parse');
      final jsonComments = parseCommentsRegEx(
        commentsResponse ?? '',
        routeId: routeId ?? -1,
        rockId: rockId ?? -1,
        areaId: areaId,
      );
      perf.stop('parse');
      perf.start('enque');
      final commentsCount = SqlHandler().enqueueInsertJsonData(
        batchComments,
        SqlHandler.ttCommentsTablename,
        jsonComments,
      );
      perf.stop('enque');
    }

    perf.start('commit');
    await SqlHandler().commitInsertJsonData(batchComments);
    perf.stop('commit');
    perf.stop('comments');

    perf.start('cache');
    // now perform the cache of mapping tables
    await SqlHandler().cacheTTMapping();
    perf.stop('cache');
    perf.printAnalysis('COMMENTS');
    count = await SqlHandler().queryCommentsCountByArea(areaId);
    return rockCount;
  }
}
