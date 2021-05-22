import 'package:flutter/material.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Material/CountryTile.dart';
import 'package:yacguide_flutter/Material/FuturesHelper.dart';

class CountryMaterial extends StatefulWidget {
  @override
  _CountryMaterialState createState() => _CountryMaterialState();
}

class _CountryMaterialState extends State<CountryMaterial> with FuturesHelper {
  Countries countries = Countries();

  _CountryMaterialState();

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: generateAppbar('Countries', true, true),
      body: futureBuilderListItems(),
    );
  }

  /// generate appbar
  AppBar generateAppbar(String title, bool buttonDelete, bool buttonUpdate) {
    return AppBar(
      title: Text('Countries'),
      actions: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            // delete all items in the database and refresh
            await countries.deleteItems();
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.update),
          onPressed: () async {
            // update items in the database from webseite and refresh list
            await countries.updateData();

            setState(() {});
          },
        ),
      ],
    );
  }

  /// prepare FutureBuilder
  FutureBuilder futureBuilderListItems() {
    return FutureBuilder<List<Country>>(
      builder: futureBuilderCountries,
      future: countries.getItems(),
/*      initialData: <Map<String, Object?>>[
        {'gebiet_ID': '1'}
      ],*/
    );
  }

  Widget futureBuilderCountries(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      // push data into protected storage
      countries.elements = snapshot.data;
      return buildCountryList();
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  /// generate Listview with all Country Data
  Widget buildCountryList() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: countries.elements.length,
      itemBuilder: (context, i) {
        final country = countries.elements[i];
        return Column(children: [
          // only first time generate a devider
          (i == 0)
              ? Divider(
                  thickness: 1,
                )
              : Container(),
          CountryTile(country),
          Divider(
            thickness: 1,
          ),
        ]);
      },
    );
  }
}
