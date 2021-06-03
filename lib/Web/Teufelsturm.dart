import 'package:http/http.dart' as http;
import 'package:rock_carrot/Web/TeufelsturmScraper.dart';
import 'package:rock_carrot/Web/WebHelper.dart';
import 'package:rock_carrot/dev/cache.dart';

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
class Teufelsturm with WebHelper, TeufelsturmScraper, CacheData {
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
}
