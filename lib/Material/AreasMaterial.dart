import 'package:flutter/material.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Material/BaseItemTile.dart';
import 'package:yacguide_flutter/Material/BaseMaterial.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';
import 'package:yacguide_flutter/Web/SandsteinSql.dart';

class AreasMaterial extends StatefulWidget {
  final Country _parentItem;
  AreasMaterial(this._parentItem);

  // transfer country to state object
  @override
  _AreasMaterialState createState() {
    return _AreasMaterialState(_parentItem);
  }
}

class _AreasMaterialState
    extends BaseItemsMaterialStatefulState<AreasMaterial> {
  /// All basic functionality is in this object (incl. parentItem)
  final Areas _areas;

  _AreasMaterialState(Country country) : _areas = Areas(country) {
    searchBar = initializeSearchBar(_areas.parentCountry.name);
  }

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: searchBar.build(context),
        // enable Refresh data with pulldown
        body: RefreshIndicator(
          onRefresh: () async {
            await Sandstein().updateAreas(_areas.parentCountry.name);
            setState(() {});
            return Future<void>.value();
          },
          child: FutureBuilder<List<Area>>(
            builder: futureBuildItemList,
            future: _areas.getAreas(),
          ),
        ));
  }

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

    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: baseitem_list.length,
      itemBuilder: (context, i) {
        final area = baseitem_list[i] as Area;
        return Column(children: [
          // only first time generate a devider
          (i == 0)
              ? Divider(
                  thickness: 1,
                )
              : Container(),
          BaseItemTile(
            area,
            updateFunction: Sandstein().updateSubareasInclComments,
            deleteFunction: Sandstein().deleteSubareasFromDatabase,
            functionParameter: area.areaId,
          ),
          Divider(
            thickness: 1,
          ),
        ]);
      },
    );
  }
}
