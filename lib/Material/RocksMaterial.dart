import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Material/FuturesHelper.dart';

class RocksMaterial extends StatefulWidget {
  final Subarea parentItem;
  RocksMaterial(this.parentItem);

  // transfer country to state object
  @override
  _RocksMaterialState createState() {
    return _RocksMaterialState(parentItem);
  }
}

class _RocksMaterialState extends State<RocksMaterial> with FuturesHelper {
  Rocks rocks;

  _RocksMaterialState(Subarea subarea) : rocks = Rocks(subarea);

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: generateAppbar(rocks.parentSubArea.sektornameD, true, true),
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
            await rocks.deleteRocksFromDatabase();
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.update),
          onPressed: () async {
            // update items in the database from webseite and refresh list
            await rocks.updateData();

            setState(() {});
          },
        ),
      ],
    );
  }

  FutureBuilder futureBuilderListItems() {
    return FutureBuilder<List<Rock>>(
      builder: futureBuilderRocks,
      future: rocks.getRocks(),
/*      initialData: <Map<String, Object?>>[
        {'gebiet_ID': '1'}
      ],*/
    );
  }

  Widget futureBuilderRocks(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      // push data into protected storage
      rocks.rocks = snapshot.data;
      return buildList();
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  FutureOr<int> deleteItems() {
    return rocks.deleteRocksFromDatabase();
  }

  FutureOr<void> fetchFromWeb() async {
    await rocks.updateData();
    // TODO: update data
    /*
    await Routes(Rock.dummyRock(rocks.parent.id)).updateData();
    await Comments(Rock.dummyRock(rocks.parent.id)).updateData();
    */
  }

  Widget buildList() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: rocks.rocks.length,
      itemBuilder: (context, i) {
        return Column(children: [
          ListTile(
            title: Text(rocks.rocks[i].gipfelName),
            trailing: Text('(' + rocks.rocks[i].routeCount.toString() + ')'),
            onTap: () {
              Navigator.pushNamed(
                  context, '/' + rocks.rocks[i].runtimeType.toString(),
                  arguments: [
                    rocks.parentSubArea,
                    rocks.rocks[i], // parent item
                  ]).then((value) {
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
