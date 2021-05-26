import 'package:flutter/material.dart';
import 'dart:async';

import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Material/FuturesHelper.dart';

class AreasMaterial extends StatefulWidget {
  final Country parentItem;
  AreasMaterial(this.parentItem);

  // transfer country to state object
  @override
  _AreasMaterialState createState() {
    return _AreasMaterialState(parentItem);
  }
}

class _AreasMaterialState extends State<AreasMaterial> with FuturesHelper {
  Areas areas;

  _AreasMaterialState(Country country) : areas = Areas(country);

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: generateAppbar(areas.parentCountry.land, true, true),
      body: futureBuilderListItems(),
    );
  }

  /// generate appbar
  AppBar generateAppbar(String title, bool buttonDelete, bool buttonUpdate) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            // delete all items in the database and refresh
            await areas.deleteAreasFromDatabase();
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.update),
          onPressed: () async {
            // update items in the database from webseite and refresh list
            await areas.updateData();

            setState(() {});
          },
        ),
      ],
    );
  }

  FutureBuilder futureBuilderListItems() {
    return FutureBuilder<List<Area>>(
      builder: futureBuilderAreas,
      future: areas.getAreas(),
    );
  }

  Widget futureBuilderAreas(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      // push data into protected storage
      areas.areas = snapshot.data;
      return buildList();
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  FutureOr<int> deleteItems() {
    return areas.deleteAreasFromDatabase();
  }

  FutureOr<void> fetchFromWeb() {
    return areas.updateData();
  }

  Widget buildList() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: areas.areas.length,
      itemBuilder: (context, i) {
        return Column(children: [
          ListTile(
            title: Text(areas.areas[i].gebiet),
            trailing: Text('(' + areas.areas[i].subareaCount.toString() + ')'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/' + areas.areas[i].runtimeType.toString(),
                arguments: areas.areas[i], // parent item
              ).then((value) {
                // refresh current page after back button is pushed to ensure new data is taken care of
                setState(() {});
              });
            },
          ),
          Divider(
            thickness: 4,
          )
        ]);
      },
    );
  }
}
