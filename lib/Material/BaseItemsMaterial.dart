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
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deleteItems();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () async {
              await fetchFromWeb();
              //refresh Scaffold
              setState(() {});
            },
          ),
        ],
      ),
      body: itemsBody(baseitem),
    );
  }

  FutureBuilder itemsBody(BaseItem parentItem) {
    return FutureBuilder(builder: baseitemsBuilder);
  }

  FutureOr<int> deleteItems();
  FutureOr<void> fetchFromWeb();

  // Dummy - to be overwritten!
  List<BaseItem> getItemsData(snapshot) {
    List<Map<String, Object?>> sqlItems = snapshot.data;
    return sqlItems.map((item) => BaseItem.fromSql(item)).toList();
  }

  Widget baseitemsBuilder(context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      print("ERROR" + snapshot.error.toString());
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
    if (!snapshot.hasData) {
      return Column(
        children: [
          SizedBox(
            child: CircularProgressIndicator(),
            width: 50,
            height: 50,
          ),
          const Padding(
            padding: EdgeInsets.all(50),
            child: Text('Loading data...'),
          )
        ],
      );
    }

    final items = getItemsData(snapshot);

    return buildList(items);
  }

  Widget buildList(List<BaseItem> items) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: items.length,
      itemBuilder: (context, i) {
        return Column(children: [
          ListTile(
            title: Text(items[i].name),
            trailing: Text("(" + items[i].childCount.toString() + ")"),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/' + items[i].runtimeType.toString(),
                arguments: items[i], // parent item
              );
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
