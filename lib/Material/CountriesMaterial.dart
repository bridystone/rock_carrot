import 'package:flutter/material.dart';

import 'AreasMaterial.dart';
import '../Baseitems/Countries.dart';

class CountryMaterial extends StatefulWidget {
  @override
  _CountryMaterialState createState() => _CountryMaterialState();
}

class _CountryMaterialState extends State<CountryMaterial> {
  Countries _countries = Countries();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Countries"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _countries.deleteItems();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () async {
              await _countries.fetchFromWeb('land');
              //refresh Scaffold
              setState(() {});
            },
          ),
        ],
      ),
      body: _countriesBody(),
    );
  }

  _countriesBody() {
    return FutureBuilder(
      future: _countries.getItems(),
      builder: _countriesBuilder,
    );
  }

  Widget _countriesBuilder(context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      print("ERROR" + snapshot.error.toString());
      return Center(
        child: Text(snapshot.error.toString()),
      );
    } else {
      if (!snapshot.hasData) {
        // TODO: Check if this is a problem -> ocurse only at first start, because futureBuilder is running, but database is not yet initialized
        // it seems not to wait for finishing the first time - is this a problem of async?!
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      List<Map<String, Object?>> sqlCountries = snapshot.data;
      final countries =
          sqlCountries.map((item) => Country.fromSql(item)).toList();

      return ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: countries.length,
        itemBuilder: (context, i) {
          return Column(children: [
            ListTile(
              title: Text(countries[i].name),
              trailing: Text("(" + countries[i].areaCount.toString() + ")"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AreasMaterial(countries[i]);
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
