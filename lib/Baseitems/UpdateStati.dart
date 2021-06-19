import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:rock_carrot/Baseitems/UpdateStatus.dart';

const String filename = 'updatestati.json';

class UpdateStati {
  List<UpdateStatus> _updateStati = [];
  // TODO: place in proper directory
  final File _fh = File(filename);

  /// initialize and get data from storage if available
  UpdateStati() {
    if (_fh.existsSync()) {
      final dynamic jsonData = jsonDecode(_fh.readAsStringSync());
      _updateStati = jsonData
          .map<UpdateStatus>((dynamic json) => UpdateStatus.fromJson(json))
          .toList();
    }
  }

  /// update current list and store to file system
  void setNewData(UpdateStatus status) {
    _updateStati.removeWhere(
      (element) => (element.type == status.type && element.id == status.id),
    );
    _updateStati.add(status);
    _fh.writeAsStringSync(json.encode(_updateStati));
  }

  /// return timestamp if available - otherwise null
  /// format is dd.mm.yyyy
  String? getTimeStamp(UpdateType type, String id) {
    final found = _updateStati.firstWhereOrNull(
      (element) => element.type == type && element.id == id,
    );

    if (found != null) {
      return DateFormat('dd.MM.yyyy').format(found.timestamp);
    }

    return null;
  }
}
