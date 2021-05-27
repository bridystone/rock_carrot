import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Material/BaseItemTile.dart';
import 'package:yacguide_flutter/Material/BaseMaterial.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';
import 'package:yacguide_flutter/Web/SandsteinSql.dart';

class CountryMaterial extends StatefulWidget {
  @override
  _CountryMaterialState createState() => _CountryMaterialState();
}

class _CountryMaterialState
    extends BaseItemsMaterialStatefulState<CountryMaterial> {
  /// All basic functionality is in this object
  final Countries _countries = Countries();

  _CountryMaterialState() {
    searchBar = initializeSearchBar(BaseItem(name: 'Countries'));
  }

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: searchBar.build(context),
        // enable Refresh data with pulldown
        body: RefreshIndicator(
          onRefresh: () async {
            await Sandstein().updateCountries();
            setState(() {});
            return Future<void>.value();
          },
          child: FutureBuilder<List<Country>>(
            builder: futureBuildItemList,
            future: _countries.getCountries(),
          ),
        ));
  }

  /// generate Listview with all Country Data
  @override
  Widget buildItemList(AsyncSnapshot snapshot) {
    // store snapshot data in local list
    baseitem_list = snapshot.data;

    // if list is empty - show message what to do...
    if (baseitem_list.isEmpty) {
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, i) {
          return Center(child: Text('Scroll down to update'));
        },
      );
    }
    // build the Widget
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: baseitem_list.length,
      itemBuilder: (context, i) {
        final country = baseitem_list[i] as Country;
        return Column(children: [
          // only first time generate a devider
          (i == 0)
              ? Divider(
                  height: 1,
                  thickness: 1,
                )
              : Container(),
          BaseItemTile(
            country,
            updateFunction: Sandstein().updateAreas,
            deleteFunction: Sandstein().deleteAreasFromDatabase,
            functionParameter: country.name,
          ),
          Divider(
            height: 1,
            thickness: 1,
          ),
        ]);
      },
    );
  }
}
