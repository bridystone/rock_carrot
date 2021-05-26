import 'package:flutter/material.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Material/AreaTile.dart';
import 'package:yacguide_flutter/Material/BaseMaterial.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';
import 'package:yacguide_flutter/Web/SandsteinSql.dart';

class AreasMaterial extends StatefulWidget {
  final Country parentItem;
  AreasMaterial(this.parentItem);

  // transfer country to state object
  @override
  _AreasMaterialState createState() {
    return _AreasMaterialState(parentItem);
  }
}

class _AreasMaterialState
    extends BaseItemsMaterialStatefulState<AreasMaterial> {
  final Areas _areas;
  List<Area> _areas_list = [];

  _AreasMaterialState(Country country) : _areas = Areas(country);

  bool sortAlpha = true;
  List<Area> get areas_list {
    if (sortAlpha) {
      _areas_list.sort(_areas.sortByName);
    } else {
      _areas_list.sort(_areas.sortByChildsDesc);
    }
    return _areas_list;
  }

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: generateAppbar(_areas.parentCountry.name),
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

  /// generate appbar
  AppBar generateAppbar(String title) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            // delete all items in the database and refresh
            await Sandstein()
                .deleteAreasFromDatabase(_areas.parentCountry.name);
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.sort_by_alpha),
          onPressed: () {
            sortAlpha = !sortAlpha;
            setState(() {});
          },
        )
      ],
    );
  }

  @override
  Widget buildItemList(AsyncSnapshot snapshot) {
    // store snapshot data in local list
    _areas_list = snapshot.data;

    // if list is empty - show message what to do...
    if (_areas_list.isEmpty) {
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, i) {
          return Center(child: Text('Scroll down to update'));
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: areas_list.length,
      itemBuilder: (context, i) {
        final area = areas_list[i];
        return Column(children: [
          // only first time generate a devider
          (i == 0)
              ? Divider(
                  thickness: 1,
                )
              : Container(),
          AreaTile(area),
          Divider(
            thickness: 1,
          ),
        ]);
      },
    );
  }
}
