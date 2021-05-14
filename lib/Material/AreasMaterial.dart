import 'package:flutter/material.dart';

import '../Baseitems/Countries.dart';
import '../Baseitems/Areas.dart';
import 'SubareasMaterial.dart';

class AreasMaterial extends StatefulWidget {
  final Country _country;
  AreasMaterial(this._country);

  // transfer country to state object
  @override
  _AreasMaterialState createState() {
    return _AreasMaterialState(this._country);
  }
}

class _AreasMaterialState extends State<AreasMaterial> {
  final Country _country;
  _AreasMaterialState(this._country);

  Areas _areas = Areas();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_country.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _areas.deleteItems(queryItem: _country.name);
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () async {
              await _areas.fetchFromWeb(
                'gebiet',
                queryKey: 'land',
                queryValue: _country.name,
              );
              //refresh Scaffold
              setState(() {});
            },
          ),
        ],
      ),
      body: _areasBody(_country.name),
    );
  }

  _areasBody(String country) {
    return FutureBuilder(
      builder: _areasBuilder,
      future: _areas.getItems(queryItem: country),
    );
  }

  Widget _areasBuilder(context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      print("ERROR" + snapshot.error.toString());
      return Center(
        child: Text(snapshot.error.toString()),
      );
    } else {
      if (snapshot.data == null) {
        // TODO: Check if this is a problem -> ocurse only at first start, because futureBuilder is running, but database is not yet initialized
        // it seems not to wait for finishing the first time - is this a problem of async?!
        return Center(
          child: Text("LOADING DATA..."),
        );
      }
      List<Map<String, Object?>> sqlAreas = snapshot.data;
      final areas = sqlAreas.map((item) => Area.fromSql(item)).toList();

      return ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: areas.length,
        itemBuilder: (context, i) {
          return Column(children: [
            ListTile(
              title: Text(areas[i].name),
              trailing: Text("(" + areas[i].subareaCount.toString() + ")"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SubAreasMaterial(areas[i]);
                  }),
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
}
