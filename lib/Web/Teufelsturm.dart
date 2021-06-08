import 'dart:async';
import 'package:pool/pool.dart';

import 'package:http/http.dart' as http;
import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlTeufelsturm.dart';
import 'package:rock_carrot/Web/TeufelsturmScraper.dart';
import 'package:rock_carrot/Web/WebHelper.dart';
import 'package:semaphore/semaphore.dart';

/// mapping of teufelsturm Area names to id
const Map<String, int> sandsteinNameTeufelsturmAreaIdMap = {
  'Gebiet der Steine': 1,
  'Bielatal': 2,
  'Schrammsteine': 3,
  'Schmilka': 4,
  'Rathen': 5,
  'Wehlen': 6,
  'Brand': 7,
  'Kleiner Zschand': 8,
  'Großer Zschand': 9,
  'Affensteine': 10,
  'Erzgebirgsgrenzgebiet': 11,
  'Wildensteiner Gebiet': 12,
  'Hinterhermsdorf': 13,
};

/// receive data from Teufelsturm via Web scraping
class Teufelsturm with WebHelper, TeufelsturmScraper {
  static final _singleton = Teufelsturm._();
  Teufelsturm._();

  factory Teufelsturm() {
    return _singleton;
  }

  /// get document data for all Rocksfrom Teufelsturm
  Future<String> fetchRocksByArea(int teufelsturmAreaId) async {
    final uri = Uri.http('teufelsturm.de', 'gipfel/suche.php');
    final response = await http.post(uri, body: {
      'anzahl': 'Alle', // all items in one page
      'gebietnr': teufelsturmAreaId.toString(),
    });
    if (isResponseValid(response)) {
      return response.body;
    } else {
      throw Exception('failed this receice data');
    }
  }

/*
  /// fetch all Route information for a dedicated Area
  Future<String> fetchRoutesByArea(int teufelsturmAreaId) async {
    final uri = Uri.http('teufelsturm.de', 'wege/suche.php');
    final response = await http.post(uri, body: {
      'anzahl': 'Alle', // all items in one page
      'gebiet': teufelsturmAreaId.toString(),
    });
    if (isResponseValid(response)) {
      return response.body;
    } else {
      throw Exception('failed this receice data');
    }
  }

  Future<String?> fetchRoutesByRock(int teufelsturmRockId) async {
    final uri = Uri.http('teufelsturm.de', 'wege/suche.php');
    /*
    final response = await http.post(uri, body: {
      'anzahl': 'Alle',
      'gipfelnr': teufelsturmRockId.toString(),
    });*/
    final http.Response response;
    try {
      response = await http.post(
        uri,
        body: {'gipfelnr': teufelsturmRockId.toString()},
      ).timeout(Duration(seconds: 1));
      if (isResponseValid(response)) {
        return response.body;
      } else {
        throw Exception('failed this receice data');
      }
    } catch (e) {
      print('TIMEOUT for rockId $teufelsturmRockId: ' + e.toString());
      return null;
    }
  }

  Future<String?> fetchCommentsByRoute(int teufelsturmRouteId) async {
    final uri = Uri.http(
      'teufelsturm.de',
      'wege/bewertungen/anzeige.php',
      // TODO: remove get-values and check, if the post still works
      <String, dynamic>{
        'wegnr': teufelsturmRouteId.toString(),
      },
    );
    // TODO: (not really - just a reminder) get requests result in hanging after a while
    // post requests seem to work as well
//    final response = await http.get(uri);
    final http.Response response;
    try {
      response = await http.post(
        uri,
        body: {'wegnr': teufelsturmRouteId.toString()},
      ).timeout(Duration(seconds: 1));
      if (isResponseValid(response)) {
        return response.body;
      } else {
        throw Exception('failed this receice data');
      }
    } catch (e) {
      print('TIMEOUT for routeId $teufelsturmRouteId: ' + e.toString());
      return null;
    }
  }
*/

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateTTComments(int areaId) async {
    /// stream that holds the requested items
    final webRequestDataControllerRoutes = StreamController<Map<String, int>>();
    final webRequestDataControllerComments =
        StreamController<Map<String, int>>();

    /// pool that limites the request
    final pool = Pool(100, timeout: Duration(seconds: 30));

    /// semaphore that signals the finish line :)
    final semaphoreRoutes = LocalSemaphore(1);

    // get Rocks of Areas ID;
    final rockResponse = await fetchRocksByArea(areaId);

    final jsonData = parseRocks(rockResponse, areaId: areaId);
    await SqlHandler().deleteTTRocks(areaId);
    final rockCount = SqlHandler().insertJsonData(
      SqlHandler.ttRocksTablename,
      jsonData,
    );

    ///
    /// ROUTES
    ///
    // get all Routes by RockID
    // remove old Routes
    await SqlHandler().deleteTTRoutesbyArea(areaId);
    // iterate through all Rocks and receive routes
    final sqlRockIds = await SqlHandler().queryRockIdsByArea(areaId);
    // prepare sql batch
    final batchRoutes = await SqlHandler().prepareInsertJsonData();

    // prepare waiting
    await semaphoreRoutes.acquire();

    /// add fetched ids to the StreamController
    for (var sqlRockId in sqlRockIds.toList()) {
      webRequestDataControllerRoutes.add({
        'id': int.tryParse(sqlRockId.values.elementAt(0).toString()) ?? -1,
        'retries': 5,
      });
    }
    // counter variable to release Semaphore
    var numberOfIds = sqlRockIds.length;

    // implementing the subscription to the Request Stream
    final routeSubscription = webRequestDataControllerRoutes.stream
        .listen((Map<String, int> data) async {
      final retries = data['retries'] ?? 0;
      final id = data['id'] ?? 0;
      http.Response? response;
      try {
        response = await pool.withResource(() => http.post(
              Uri.http(
                'teufelsturm.de',
                'wege/suche.php',
              ),
              body: {'gipfelnr': id.toString()},
            ));
      } catch (e) {
        print('$id: $e');
      }
      if (response == null || response.statusCode != 200) {
        if (retries > 0) {
          data['retries'] = retries - 1;
          webRequestDataControllerRoutes.sink.add(data);
          print('$id readded');
        }
      } else {
        /// response is valid ==> perform actions
        final jsonRoutes = parseRoutesRegEx(
          response.body,
          rockId: id,
          areaId: areaId,
        );
        final routesCount = SqlHandler().enqueueInsertJsonData(
          batchRoutes,
          SqlHandler.ttRoutesTablename,
          jsonRoutes,
        );

        /// count ids for semaphore to be released
        if (--numberOfIds == 0) {
          semaphoreRoutes.release();
        }
      }
    });

    //wait for requests to finish
    await semaphoreRoutes.acquire();
    semaphoreRoutes.release();
    // perform commit
    await SqlHandler().commitInsertJsonData(batchRoutes);

    ///
    ///COMMENTS
    ///
    // first remove old comments
    await SqlHandler().deleteTTCommentsbyArea(areaId);

    // iterate through all Routes and receive comments
    final sqlRoutes = await SqlHandler().queryRouteIdsByArea(areaId);
    // prepare sql batch
    final batchComments = await SqlHandler().prepareInsertJsonData();

    final semaphoreComments = LocalSemaphore(1);
    //wait for requests to finish
    await semaphoreComments.acquire();

    /// add fetched ids to the StreamController
    for (var sqlRoutesId in sqlRoutes.toList()) {
      webRequestDataControllerComments.add({
        'routeid':
            int.tryParse(sqlRoutesId.values.elementAt(0).toString()) ?? -1,
        'rockid':
            int.tryParse(sqlRoutesId.values.elementAt(1).toString()) ?? -1,
        'retries': 5,
      });
    }
    // counter variable to release Semaphore
    var numberOfCommentIds = sqlRoutes.length;

    // implementing the subscription to the Request Stream
    final routeSubscriptionComments = webRequestDataControllerComments.stream
        .listen((Map<String, int> data) async {
      final retries = data['retries'] ?? 0;
      final id = data['routeid'] ?? -1;
      final rockId = data['rockid'] ?? -1;
      http.Response? response;
      try {
        response = await pool.withResource(() => http.post(
              Uri.http(
                'teufelsturm.de',
                'wege/bewertungen/anzeige.php',
              ),
              body: {'wegnr': id.toString()},
            ));
      } catch (e) {
        print('$id: $e');
      }
      if (response == null || response.statusCode != 200) {
        if (retries > 0) {
          data['retries'] = retries - 1;
          webRequestDataControllerComments.sink.add(data);
          print('$id readded');
        }
      } else {
        /// response is valid ==> perform actions
        final jsonComments = parseCommentsRegEx(
          response.body,
          routeId: id,
          rockId: rockId,
          areaId: areaId,
        );
        final routesCount = SqlHandler().enqueueInsertJsonData(
          batchComments,
          SqlHandler.ttCommentsTablename,
          jsonComments,
        );

        /// count ids for semaphore to be released
        if (--numberOfCommentIds == 0) {
          semaphoreComments.release();
        }
      }
    });

    //wait for requests to finish
    await semaphoreComments.acquire();
    semaphoreComments.release();

    // perform commit
    await SqlHandler().commitInsertJsonData(batchComments);

    // now perform the cache of mapping tables
    await SqlHandler().cacheTTMapping();

    return rockCount;
  }
}
