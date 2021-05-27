import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';

abstract class BaseItemsMaterialStatefulState<T extends StatefulWidget>
    extends State<T> {
  /// Searchbar functionality
  ///
  /// generate Searchbar in AppBar
  /// any search will transfer data to the [searchBarValue]
  /// this will change the outcome of the [baseitem_list] getter
  late SearchBar searchBar;
  String searchBarValue = '';

  /// initialize Searchbar
  SearchBar initializeSearchBar(String appBarTitle) {
    return SearchBar(
      inBar: false,
      hintText: 'enter Text',
      // TODO: understand this? why setState?
      setState: setState,
      // add default appBar without Search
      buildDefaultAppBar: (BuildContext context) => generateAppbar(appBarTitle),
      // handle callbacks
      onChanged: (String value) => setState(() {
        searchBarValue = value;
      }),
      onCleared: () => setState(() {
        searchBarValue = '';
      }),
      onClosed: () => setState(() {
        searchBarValue = '';
      }),
      closeOnSubmit: true,
    );
  }

  /// Appbar generation
  AppBar generateAppbar(String title) {
    return AppBar(
      title: Text(title),
      actions: [
        // sort by name ASC or childcount DESC
        IconButton(
          icon: Icon(Icons.sort_by_alpha),
          onPressed: () {
            sortAlpha = !sortAlpha;
            setState(() {});
          },
        ),
        // add Searchbar Action
        searchBar.getSearchAction(context),
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

  /// the actual data for presentation
  List<BaseItem> _baseitem_list = [];

  /// item for _baseitems functionality (sorting)
  final BaseItems _baseitems = BaseItems();

  bool sortAlpha = true;
  set baseitem_list(List<BaseItem> new_list) {
    _baseitem_list = new_list;
  }

  List<BaseItem> get baseitem_list {
    if (sortAlpha) {
      _baseitem_list.sort(_baseitems.sortByName);
    } else {
      _baseitem_list.sort(_baseitems.sortByChildsDesc);
    }
    // checking the search
    if (searchBarValue.isEmpty) {
      return _baseitem_list;
    } else {
      return _baseitem_list
          .where((element) => element.name!
              .toLowerCase()
              .contains(searchBarValue.toLowerCase()))
          .toList();
    }
  }

  /// abstract function to get futures to concrete data
  Widget buildItemList(AsyncSnapshot snapshot);

  /// futureBuilder for receiving SQL Data
  Widget futureBuildItemList(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      return buildItemList(snapshot);
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  /// Loading message for Futures
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

  /// Error Message for futures
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
}
