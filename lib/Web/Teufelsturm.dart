import 'dart:async';
import 'package:pool/pool.dart';

import 'package:http/http.dart' as http;
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Baseitems/UpdateStati.dart';
import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlTeufelsturm.dart';
import 'package:rock_carrot/Material/ProgressNotifier.dart';
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
const List<int> teufelsturmAreaIdSandsteinSubareaIdMap = [
  0, // nothing
  133, //1
  124,
  132,
  131,
  130,
  134,
  128,
  129,
  126,
  123,
  125,
  135,
  127, //13
];

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

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateTTComments(
      Subarea subarea, ProgressNotifier progress) async {
    final ttAreaId = sandsteinNameTeufelsturmAreaIdMap[subarea.name]!;

    /// stream that holds the requested items
    final webRequestDataControllerRoutes = StreamController<Map<String, int>>();
    final webRequestDataControllerComments =
        StreamController<Map<String, int>>();

    /// pool that limites the request
    final pool = Pool(50, timeout: Duration(seconds: 30));

    /// semaphore that signals the finish line :)
    final semaphoreRoutes = LocalSemaphore(1);

    progress.startProgress('Rocks');
    // get Rocks of Areas ID;
    final rockResponse = await fetchRocksByArea(ttAreaId);

    progress.updatePercentage(33);

    final jsonData = parseRocks(rockResponse, areaId: ttAreaId);

    progress.updatePercentage(66);

    await SqlHandler().deleteTTRocks(ttAreaId);
    final rockCount = SqlHandler().insertJsonData(
      SqlHandler.ttRocksTablename,
      jsonData,
    );

    progress.finishProgress();

    progress.startProgress('Routes');

    ///
    /// ROUTES
    ///
    // get all Routes by RockID
    // remove old Routes
    await SqlHandler().deleteTTRoutesbyArea(ttAreaId);
    // iterate through all Rocks and receive routes
    final sqlRockIds = await SqlHandler().queryRockIdsByArea(ttAreaId);
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
    webRequestDataControllerRoutes.stream.listen((Map<String, int> data) async {
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
          areaId: ttAreaId,
        );
        final routesCount = SqlHandler().enqueueInsertJsonData(
          batchRoutes,
          SqlHandler.ttRoutesTablename,
          jsonRoutes,
        );

        // update progress
        final percent =
            (sqlRockIds.length - numberOfIds) * 100 ~/ sqlRockIds.length;
        progress.updatePercentage(percent);

        /// count ids for semaphore to be released
        if (--numberOfIds == 0) {
          semaphoreRoutes.release();
        }
      }
    });

    //wait for requests to finish
    await semaphoreRoutes.acquire();
    semaphoreRoutes.release();

    progress.finishProgress();
    // perform commit
    await SqlHandler().commitInsertJsonData(batchRoutes);

    progress.startProgress('Comments');

    ///
    ///COMMENTS
    ///
    // first remove old comments
    await SqlHandler().deleteTTCommentsbyArea(ttAreaId);

    // iterate through all Routes and receive comments
    final sqlRoutes = await SqlHandler().queryRouteIdsByArea(ttAreaId);
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
    webRequestDataControllerComments.stream
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
          areaId: ttAreaId,
        );
        final routesCount = SqlHandler().enqueueInsertJsonData(
          batchComments,
          SqlHandler.ttCommentsTablename,
          jsonComments,
        );

        final percent =
            (sqlRoutes.length - numberOfCommentIds) * 100 ~/ sqlRoutes.length;
        progress.updatePercentage(percent);

        /// count ids for semaphore to be released
        if (--numberOfCommentIds == 0) {
          semaphoreComments.release();
        }
      }
    });

    //wait for requests to finish
    await semaphoreComments.acquire();
    semaphoreComments.release();

    progress.finishProgress();
    // perform commit
    await SqlHandler().commitInsertJsonData(batchComments);

    progress.startProgress('Caching');
    // now perform the cache of mapping tables
    await SqlHandler().cacheTTMapping(ttAreaId);
    progress.finishProgress();

    // store update time in json
    (await UpdateStati.getInstance()).setNewData(subarea, true);

    return rockCount;
  }
}
