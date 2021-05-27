import 'package:flutter/material.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Material/BaseItemTile.dart';
import 'package:yacguide_flutter/Material/BaseMaterial.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';
import 'package:yacguide_flutter/Web/SandsteinSql.dart';

class SubAreasMaterial extends StatefulWidget {
  final Area _parentItem;
  SubAreasMaterial(this._parentItem);

  // transfer country to state object
  @override
  _SubAreasMaterialState createState() {
    return _SubAreasMaterialState(_parentItem);
  }
}

class _SubAreasMaterialState
    extends BaseItemsMaterialStatefulState<SubAreasMaterial> {
  /// All basic functionality is in this object (incl. parentItem)
  final Subareas _subareas;

  _SubAreasMaterialState(Area area) : _subareas = Subareas(area) {
    searchBar = initializeSearchBar(_subareas.parentArea);
    // default sorting ist by child count
    sortAlpha = false;
  }

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: searchBar.build(context),
        // enable Refresh data with pulldown
        body: RefreshIndicator(
          onRefresh: () async {
            await Sandstein()
                .updateSubareasInclComments(_subareas.parentArea.areaId);
            setState(() {});
            return Future<void>.value();
          },
          child: FutureBuilder<List<Subarea>>(
            builder: futureBuildItemList,
            future: _subareas.getSubareas(),
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
        final subarea = baseitem_list[i] as Subarea;
        return Column(children: [
          // only first time generate a devider
          (i == 0)
              ? Divider(
                  height: 1,
                  thickness: 1,
                )
              : Container(),
          BaseItemTile(
            subarea,
            updateFunction: Sandstein().updateRocksIncludingSubitems,
            deleteFunction: Sandstein().deleteRocksFromDatabase,
            functionParameter: subarea.subareaId,
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
