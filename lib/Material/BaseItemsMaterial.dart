import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';

abstract class BaseItemsMaterialStatefulState<T extends StatefulWidget>
    extends State<T> {
  BaseItem baseitem;
  BaseItemsMaterialStatefulState(this.baseitem);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(baseitem.name),
        // TODO: add show comments for subareas & rocks
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await deleteItems();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () async {
              //refresh Scaffold
              await fetchFromWeb();

              setState(() {});
            },
          ),
        ],
      ),
      body: futureBuilderListItems(baseitem),
    );
  }

  FutureBuilder futureBuilderListItems(BaseItem parentItem);

  FutureOr<int> deleteItems();
  FutureOr<void> fetchFromWeb();

  Widget baseitemsBuilder(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      return buildList(snapshot.data);
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  Widget futureBuilderErrorMessage(AsyncSnapshot snapshot) {
    print('ERROR' + snapshot.error.toString());
    return Column(children: [
      Icon(
        Icons.error_outline,
        color: Colors.yellow,
        size: 50,
      ),
      Padding(
        padding: EdgeInsets.all(60),
        child: Text(snapshot.error.toString()),
      ),
    ]);
  }

  Widget futureBuilderLoadingMessage(AsyncSnapshot snapshot) {
    final message = 'Loading data... ${snapshot.connectionState.toString()}';
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: EdgeInsets.all(50),
          child: Text(message),
        )
      ],
    );
  }

  Widget buildList(List<BaseItem> items) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: items.length,
      itemBuilder: (context, i) {
        return Column(children: [
          ListTile(
            title: Text(items[i].name),
            trailing: Text('(' + items[i].childCount.toString() + ')'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/' + items[i].runtimeType.toString(),
                arguments: items[i], // parent item
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
