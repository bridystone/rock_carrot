import 'dart:async';

import 'package:pedantic/pedantic.dart';
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
  Future<int> updateAreas(String countryName) async {
    var jsonData = fetchJsonFromWeb(
      Sandstein.areasWebTarget,
      Sandstein.areasWebQuery,
      countryName,
    );
    await SqlHandler().deleteAreas(countryName);
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
  Future<int> updateSubareasInclComments(int areaId) async {
    // fetch data from subareas + comments
    final jsonDataSubareas = fetchJsonFromWeb(
      Sandstein.subareasWebTarget,
      Sandstein.subareasWebQuery,
      areaId.toString(),
    );
    final jsonDataComments = fetchJsonFromWeb(
      Sandstein.commentsWebTarget,
      Sandstein.commentsWebQuerySubareas,
      areaId.toString(),
    );

    // delete old data
    await SqlHandler().deleteSubareasIncludingComments(areaId);

    // insert new data
    await SqlHandler()
        .insertJsonData(SqlHandler.commentsTablename, jsonDataComments);
    return await SqlHandler()
        .insertJsonData(SqlHandler.subareasTablename, jsonDataSubareas);
  }

  /// update data from Sandsteinklettern
  ///
  /// This is a combination of Subareas fetch
  /// with All Rock Data (incl. subitems)
  Future<int> updateSubareasInclAllSubitems(
      int areaId, ProgressNotifier progress) async {
    progress.startProgress('Subareas');
    // update subareas
    final result = await updateSubareasInclComments(areaId);
    progress.finishProgress();
    // get results from database and iterate through all items
    final sqlResults = await SqlHandler().querySubareas(areaId);
    progress.startProgress('Rocks');
    var percentageCounter = sqlResults.length;

    for (var sqlRow in sqlResults) {
      await updateRocksIncludingSubitems(
          int.parse(sqlRow.values.elementAt(0).toString()));
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
  Future<int> updateRocksIncludingSubitems(int subareaId) async {
    final jsonDataRocks = fetchJsonFromWeb(
      Sandstein.rocksWebTarget,
      Sandstein.rocksWebQuery,
      subareaId.toString(),
    );
    final jsonDataRoutes = fetchJsonFromWeb(
      Sandstein.routesWebTarget,
      Sandstein.routesWebQuery,
      subareaId.toString(),
    );
    final jsonDataComments = fetchJsonFromWeb(
      Sandstein.commentsWebTarget,
      Sandstein.commentsWebQueryRocks,
      subareaId.toString(),
    );
    // delete all data
    await SqlHandler().deleteRocksIncludingSubitems(subareaId);

    // insert new data
    await SqlHandler()
        .insertJsonData(SqlHandler.commentsTablename, jsonDataComments);
    await SqlHandler()
        .insertJsonData(SqlHandler.routesTablename, jsonDataRoutes);

    return await SqlHandler()
        .insertJsonData(SqlHandler.rocksTablename, jsonDataRocks);
  }
}
