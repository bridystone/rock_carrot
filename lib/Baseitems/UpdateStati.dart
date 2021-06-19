import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rock_carrot/Baseitems/Areas.dart';
import 'package:rock_carrot/Baseitems/BaseItems.dart';
import 'package:rock_carrot/Baseitems/Countries.dart';
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Baseitems/UpdateStatus.dart';

const String filename = 'updatestati.json';

class UpdateStati {
  static UpdateStati? _singleton;
  UpdateStati._private();

  // ensure singleton is only initiated once
  // https://medium.com/@dexcell/dart-singleton-async-cb605a10fd60
  static final _initUpdateStatiMemoizer = AsyncMemoizer<UpdateStati>();

  /// return Single Instance of UpdateStati
  static Future<UpdateStati> getInstance() async {
    // prevent race conditions
    return _singleton ??= await _initUpdateStatiMemoizer.runOnce(() async {
      await UpdateStati._loadData();
      return UpdateStati._private();
    });
  }

  // needs to be late due to async not able in constructor
  // and getApplicationSupportDirectory is async :(
  static late final File _fh;
  static late final List<UpdateStatus> _updateStati;

  /// initialize and get data from storage if available
  /// loading data from storage
  /// only to be called from getInstance
  static Future<void> _loadData() async {
    final dir = await getApplicationSupportDirectory();
    _fh = File(dir.path + filename);

    if (await _fh.exists()) {
      final dynamic jsonData = jsonDecode(await _fh.readAsString());
      _updateStati = jsonData
          .map<UpdateStatus>((dynamic json) => UpdateStatus.fromJson(json))
          .toList();
    } else {
      _updateStati = [];
    }
  }

  /// update current list and store to file system
  void setNewData(BaseItem baseitem, [bool isTTUpdate = false]) {
    UpdateType filterType;
    String filterId;
    if (baseitem is Country) {
      filterType = UpdateType.country;
      filterId = baseitem.name;
    } else if (baseitem is Area) {
      filterType = UpdateType.area;
      filterId = baseitem.areaId.toString();
    } else if (baseitem is Subarea) {
      if (isTTUpdate) {
        filterType = UpdateType.teufelsturm;
//        filterId = sandsteinNameTeufelsturmAreaIdMap[baseitem.name].toString();
      } else {
        filterType = UpdateType.subarea;
      }
      filterId = baseitem.subareaId.toString();
    } else {
      throw Exception('Not Implemented');
    }
    _updateStati.removeWhere(
      (element) => (element.type == filterType && element.id == filterId),
    );
    _updateStati.add(
      UpdateStatus(
        filterType,
        filterId,
        DateTime.now(),
      ),
    );
    _fh.writeAsStringSync(json.encode(_updateStati));
  }

  /// return timestamp if available - otherwise null
  DateTime? getTimeStamp(UpdateType type, String id) {
    final found = _updateStati.firstWhereOrNull(
      (element) => element.type == type && element.id == id,
    );
    return found?.timestamp;
  }
}
