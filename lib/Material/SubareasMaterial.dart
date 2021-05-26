import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Material/FuturesHelper.dart';

class SubAreasMaterial extends StatefulWidget {
  final Area parentItem;
  SubAreasMaterial(this.parentItem);

  // transfer country to state object
  @override
  _SubAreasMaterialState createState() {
    return _SubAreasMaterialState(parentItem);
  }
}

class _SubAreasMaterialState extends State<SubAreasMaterial>
    with FuturesHelper {
  Subareas subareas;

  _SubAreasMaterialState(Area area) : subareas = Subareas(area);

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: generateAppbar(subareas.parentArea.gebiet, true, true),
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
            await subareas.deleteSubareasFromDatabase();
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.update),
          onPressed: () async {
            // update items in the database from webseite and refresh list
            await subareas.updateData();

            setState(() {});
          },
        ),
      ],
    );
  }

  FutureBuilder futureBuilderListItems() {
    return FutureBuilder<List<Subarea>>(
      builder: futureBuilderSubareas,
      future: subareas.getSubareas(),
    );
  }

  Widget futureBuilderSubareas(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      // push data into protected storage
      subareas.subareas = snapshot.data;
      return buildList();
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  /// delete subareas & its comments
  FutureOr<int> deleteItems() {
    return subareas.deleteSubareasFromDatabase();
  }

  /// receive subareas & comments from db sandsteinklettern
  ///
  /// tables will be cleared & rewritten

  FutureOr<void> fetchFromWeb() async {
    await subareas.updateData();
    // TODO: update Comments!!
    /*
    await Comments(Subarea.dummySubarea(subareas.parent.id)).updateData();
    */
  }

  Widget buildList() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: subareas.subareas.length,
      itemBuilder: (context, i) {
        return Column(children: [
          ListTile(
            title: Text(subareas.subareas[i].sektornameD),
            trailing:
                Text('(' + subareas.subareas[i].rockCount.toString() + ')'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/' + subareas.subareas[i].runtimeType.toString(),
                arguments: subareas.subareas[i], // parent item
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
