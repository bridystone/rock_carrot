import 'package:flutter/material.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Material/BaseItemTile.dart';
import 'package:yacguide_flutter/Material/BaseMaterial.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';
import 'package:yacguide_flutter/Web/SandsteinSql.dart';

class RocksMaterial extends StatefulWidget {
  final Subarea parentItem;
  RocksMaterial(this.parentItem);

  // transfer country to state object
  @override
  _RocksMaterialState createState() {
    return _RocksMaterialState(parentItem);
  }
}

class _RocksMaterialState
    extends BaseItemsMaterialStatefulState<RocksMaterial> {
  final Rocks _rocks;

  _RocksMaterialState(Subarea subarea) : _rocks = Rocks(subarea) {
    searchBar = initializeSearchBar(_rocks.parentSubArea.name);
    // default sorting ist by number
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
                .updateRocksIncludingSubitems(_rocks.parentSubArea.subareaId);
            setState(() {});
            return Future<void>.value();
          },
          child: FutureBuilder<List<Rock>>(
            builder: futureBuildItemList,
            future: _rocks.getRocks(),
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
        final rock = baseitem_list[i] as Rock;
        return Column(children: [
          // only first time generate a devider
          (i == 0)
              ? Divider(
                  thickness: 1,
                )
              : Container(),
          BaseItemTile(
            rock,
          ),
          Divider(
            thickness: 1,
          ),
        ]);
      },
    );
  }
}
