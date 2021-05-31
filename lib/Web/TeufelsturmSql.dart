import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlTeufelsturm.dart';
import 'package:rock_carrot/Web/Teufelsturm.dart';

extension TeufelsturmSql on Teufelsturm {
  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateTTComments(int areaId) async {
    // get Rocks of Areas ID;
    final rockResponse = await fetchRocksByArea(areaId);
    final jsonData = parseRocks(rockResponse, areaId: areaId);
    await SqlHandler().deleteTTRocks(areaId);
    final rockCount = SqlHandler().insertJsonData(
      SqlHandler.ttRocksTablename,
      jsonData,
    );

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
    // get all Routes by RockID
    // remove old Routes
    await SqlHandler().deleteTTRoutesbyArea(areaId);
    // iterate through all Rocks and receive routes
    final sqlRockIds = await SqlHandler().queryRockIdsByArea(areaId);
    final batchRoutes = await SqlHandler().prepareInsertJsonData();
    for (var sqlRockId in sqlRockIds.toList()) {
      final rockId = int.tryParse(sqlRockId.values.elementAt(0).toString());
      //perform number of retries
      String? routeResponse;
      var retries = 5;
      while ((routeResponse = await fetchRoutesByRock(rockId ?? 0)) == null) {
        if (--retries <= 0) {
          print('TOO MUCH RETRIES for areaId $areaId');
          break;
        }
      }
      final jsonRoutes = parseRoutes(
        routeResponse ?? '',
        rockId: rockId ?? 0,
        areaId: areaId,
      );
      final routesCount = SqlHandler().enqueueInsertJsonData(
        batchRoutes,
        SqlHandler.ttRoutesTablename,
        jsonRoutes,
      );
    }
    await SqlHandler().commitInsertJsonData(batchRoutes);

    // first remove old comments
    await SqlHandler().deleteTTCommentsbyArea(areaId);
    final batchComments = await SqlHandler().prepareInsertJsonData();
    var count = await SqlHandler().queryCommentsByArea(areaId);
    // iterate through all Routes and receive comments
    final sqlRoutes = await SqlHandler().queryRouteIdsByArea(areaId);
    for (var sqlRouteId in sqlRoutes.toList()) {
      final routeId = int.tryParse(sqlRouteId.values.elementAt(0).toString());

      //perform number of retries
      String? commentsResponse;
      var retries = 5;
      while ((commentsResponse = await fetchCommentsByRoute(routeId ?? 0)) ==
          null) {
        if (--retries <= 0) {
          print('TOO MUCH RETRIES for areaId $areaId');
          break;
        }
      }
//      final commentsResponse = await fetchCommentsByRoute(routeId ?? 0);
      final jsonComments = parseCommentsRegEx(
        commentsResponse ?? '',
        routeId: routeId ?? 0,
        areaId: areaId,
      );
      final commentsCount = SqlHandler().enqueueInsertJsonData(
        batchComments,
        SqlHandler.ttCommentsTablename,
        jsonComments,
      );
    }
    await SqlHandler().commitInsertJsonData(batchComments);
    count = await SqlHandler().queryCommentsCountByArea(areaId);
    return rockCount;
  }
}
