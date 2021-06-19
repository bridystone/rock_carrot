import 'dart:async';

import 'package:rock_carrot/Baseitems/Areas.dart';
import 'package:rock_carrot/Baseitems/Countries.dart';
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Baseitems/UpdateStati.dart';
import 'package:rock_carrot/Database/sql.dart';
import 'package:rock_carrot/Database/sqlCountries.dart';
import 'package:rock_carrot/Database/sqlAreas.dart';
import 'package:rock_carrot/Database/sqlSubareas.dart';
import 'package:rock_carrot/Database/sqlRocks.dart';
import 'package:rock_carrot/Material/ProgressNotifier.dart';
import 'package:rock_carrot/Web/Sandstein.dart';

extension SandsteinSql on Sandstein {
  /// delete all data from Countries-Table
  Future<int> deleteCountriesFromDatabase() {
    return SqlHandler().deleteCountries();
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateCountries() async {
    var jsonData = fetchJsonFromWeb(Sandstein.countriesWebTarget);
    await SqlHandler().deleteCountries();
    return SqlHandler().insertJsonData(SqlHandler.countriesTablename, jsonData);
  }

// TODO: remove from final version
  FutureOr<int> deleteAreasFromDatabase(String countryName) {
    return SqlHandler().deleteAreas(countryName);
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateAreas(Country country) async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.areasWebTarget,
      Sandstein.areasWebQuery,
      country.name,
    );
    await SqlHandler().deleteAreas(country.name);

    // store update time in json
    (await UpdateStati.getInstance()).setNewData(country);

    return SqlHandler().insertJsonData(SqlHandler.areasTablename, jsonData);
  }

  /// delete all subareas including their comemnts
  /// TODO: get rid of in final
  FutureOr<int> deleteSubareasFromDatabase(int areaId) {
    return SqlHandler().deleteSubareasIncludingComments(areaId);
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateSubareasInclComments(Area area) async {
    // fetch data from subareas + comments
    // delete old data
    await SqlHandler().deleteSubareasIncludingComments(area.areaId);

    final jsonDataSubareas = fetchJsonFromWeb(
      Sandstein.subareasWebTarget,
      Sandstein.subareasWebQuery,
      area.areaId.toString(),
    );
    final count = await SqlHandler()
        .insertJsonData(SqlHandler.subareasTablename, jsonDataSubareas);

    final jsonDataComments = fetchJsonFromWeb(
      Sandstein.commentsWebTarget,
      Sandstein.commentsWebQuerySubareas,
      area.areaId.toString(),
    );

    // insert new data
    await SqlHandler()
        .insertJsonData(SqlHandler.commentsTablename, jsonDataComments);

    // store update time in json
    (await UpdateStati.getInstance()).setNewData(area);

    return count;
  }

  /// update data from Sandsteinklettern
  ///
  /// This is a combination of Subareas fetch
  /// with All Rock Data (incl. subitems)
  Future<int> updateSubareasInclAllSubitems(
    Area area,
    ProgressNotifier progress,
  ) async {
    progress.startProgress('Subareas');
    // update subareas
    final result = await updateSubareasInclComments(area);
    progress.finishProgress();
    // get results from database and iterate through all items
    final sqlResults = await SqlHandler().querySubareas(area.areaId);
    progress.startProgress('Rocks');
    var percentageCounter = sqlResults.length;

    for (var sqlRow in sqlResults) {
      await updateRocksIncludingSubitems(Subarea(
        int.parse(sqlRow.values.elementAt(0).toString()),
        -1,
        '__dummy__',
        '__dummy__',
        '__dummy__',
        -1,
        -1,
      ));
      final percent =
          (sqlResults.length - --percentageCounter) * 100 ~/ sqlResults.length;
      progress.updatePercentage(percent);
    }
    progress.finishProgress();
    // return result from subareas fetch
    return result;
  }

  // TODO: get rid of
  Future<int> deleteRocksFromDatabase(int subareaId) {
    // delete Routes as well with a dummy Rock Items
    return SqlHandler().deleteRocksIncludingSubitems(subareaId);
  }

  /// update data from Sandsteinklettern
  ///
  /// fetch the data, then delete records, finally insert new data
  Future<int> updateRocksIncludingSubitems(Subarea subarea) async {
    // delete all data
    await SqlHandler().deleteRocksIncludingSubitems(subarea.subareaId);

    final jsonDataRocks = fetchJsonFromWeb(
      Sandstein.rocksWebTarget,
      Sandstein.rocksWebQuery,
      subarea.subareaId.toString(),
    );
    final count = await SqlHandler()
        .insertJsonData(SqlHandler.rocksTablename, jsonDataRocks);

    final jsonDataRoutes = fetchJsonFromWeb(
      Sandstein.routesWebTarget,
      Sandstein.routesWebQuery,
      subarea.subareaId.toString(),
    );
    await SqlHandler()
        .insertJsonData(SqlHandler.routesTablename, jsonDataRoutes);

    final jsonDataComments = fetchJsonFromWeb(
      Sandstein.commentsWebTarget,
      Sandstein.commentsWebQueryRocks,
      subarea.subareaId.toString(),
    );

    // insert new data
    await SqlHandler()
        .insertJsonData(SqlHandler.commentsTablename, jsonDataComments);

    // store update time in json
    (await UpdateStati.getInstance()).setNewData(subarea);

    return count;
  }
}
