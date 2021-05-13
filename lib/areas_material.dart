import 'package:flutter/material.dart';
import 'Areas.dart';
import 'subareas_material.dart';

class AreasMaterial extends StatefulWidget {
  final String country;
  AreasMaterial(this.country);

  // transfer country to state object
  @override
  _AreasMaterialState createState() {
    return _AreasMaterialState(this.country);
  }
}

class _AreasMaterialState extends State<AreasMaterial> {
  final String country;
  _AreasMaterialState(this.country);

  Areas _areas = Areas();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(country),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _areas.deleteAreas(country);
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () async {
              await _areas.fetchAreas(country);
              //refresh Scaffold
              setState(() {});
            },
          ),
        ],
      ),
      body: _areasBody(country),
    );
  }

  _areasBody(String country) {
    return FutureBuilder(
        builder: _areasBuilder, future: _areas.getAreas(country));
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
                    return SubAreasMaterial(areas[i].name);
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
