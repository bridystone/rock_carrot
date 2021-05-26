import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Material/BaseMaterial.dart';
import 'package:yacguide_flutter/Material/CountryTile.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';
import 'package:yacguide_flutter/Web/SandsteinSql.dart';

class CountryMaterial extends StatefulWidget {
  @override
  _CountryMaterialState createState() => _CountryMaterialState();
}

class _CountryMaterialState
    extends BaseItemsMaterialStatefulState<CountryMaterial> {
  final Countries _countries = Countries();
  List<Country> _countries_list = [];

  late SearchBar _searchBar;
  String _searchBarValue = '';

  _CountryMaterialState() {
    _searchBar = SearchBar(
      inBar: false,
      hintText: 'enter Text',
      setState: setState,
      buildDefaultAppBar: (BuildContext context) => generateAppbar('Countries'),
      onChanged: (String value) => setState(() {
        _searchBarValue = value;
      }),
      onCleared: () => setState(() {
        _searchBarValue = '';
      }),
      onClosed: () => setState(() {
        _searchBarValue = '';
      }),
      closeOnSubmit: true,
    );
  }

  bool sortAlpha = true;
  List<Country> get countries_list {
    if (sortAlpha) {
      _countries_list.sort(_countries.sortByName);
    } else {
      _countries_list.sort(_countries.sortByChildsDesc);
    }
    // checking the search
    if (_searchBarValue.isEmpty) {
      return _countries_list;
    } else {
      return _countries_list
          .where((element) => element.name
              .toLowerCase()
              .contains(_searchBarValue.toLowerCase()))
          .toList();
    }
  }

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _searchBar.build(context),
        // generateAppbar('Countries'),
        body: RefreshIndicator(
          onRefresh: () async {
            await Sandstein().updateCountries();
            setState(() {});
            return Future<void>.value();
          },
          child: FutureBuilder<List<Country>>(
            builder: futureBuildItemList,
            future: _countries.getCountries(),
          ),
        ));
  }

  /// generate appbar
  AppBar generateAppbar(String title) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_forever),
          onPressed: () async {
            // delete all items in the database and refresh
            await Sandstein().deleteCountriesFromDatabase();
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.sort_by_alpha),
          onPressed: () {
            sortAlpha = !sortAlpha;
            setState(() {});
          },
        ),
        _searchBar.getSearchAction(context),
        /*
        IconButton(
          icon: Icon(Icons.update),
          onPressed: () async {
            // show modal dialog while unpdating data from Web to Database
            await showModalBottomSheet<void>(
              isDismissible: false,
              context: context,
              builder: (BuildContext context) => FutureBuilder(
                builder: futureBuilderUpdateLoading,
                future: Sandstein().updateCountries(),
              ),
            );
            // invalidate the whole scaffold
            setState(() {});
          },
        ),*/
      ],
    );
  }

/*
  // TODO: modal dialog for long running updates!
  /// handle modal dialog box for updating data
  Widget futureBuilderUpdateLoading(
      BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      // autoclose dialog when finished
      Navigator.of(context).pop();
      // push data into protected storage
      return Text('Finished');
    }

    return futureBuilderLoadingMessage(snapshot);
  }
*/
  /// generate Listview with all Country Data
  @override
  Widget buildItemList(AsyncSnapshot snapshot) {
    // store snapshot data in local list
    _countries_list = snapshot.data;

    // if list is empty - show message what to do...
    if (_countries_list.isEmpty) {
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, i) {
          return Center(child: Text('Scroll down to update'));
        },
      );
    }
    // build the Widget
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: countries_list.length,
      itemBuilder: (context, i) {
        final country = countries_list[i];
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
