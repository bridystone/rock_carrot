import 'dart:io';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:rock_carrot/Baseitems/Areas.dart';
import 'package:rock_carrot/Baseitems/BaseItems.dart';
import 'package:rock_carrot/Baseitems/Rocks.dart';
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Material/CommentsSheet.dart';
import 'package:rock_carrot/Material/FutureBuilderHelper.dart';

abstract class BaseItemsMaterialStatefulState<T extends StatefulWidget>
    extends State<T> with FutureBuilderHelper {
  /// Searchbar functionality
  ///
  /// generate Searchbar in AppBar
  /// any search will transfer data to the [searchBarValue]
  /// this will change the outcome of the [baseitem_list] getter
  late SearchBar searchBar;
  String searchBarValue = '';

  /// initialize Searchbar
  SearchBar initializeSearchBar(BaseItem baseitem) {
    return SearchBar(
      inBar: false,
      hintText: 'enter Text',
      // TODO: understand this? why setState?
      setState: setState,
      // add default appBar without Search
      buildDefaultAppBar: (BuildContext context) => generateAppbar(baseitem),
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
  AppBar generateAppbar(BaseItem baseitem) {
    // prepare icon Buttons
    List<Widget>? iconButtons = [];
    // check, if comment item will be generated
    if (baseitem is Area || baseitem is Subarea || baseitem is Rock) {
      if (baseitem.commentCountInt! > 0) {
        iconButtons.add(IconButton(
          icon: Icon(
            Icons.comment,
          ),
          onPressed: () {
            CommentsSheet().showCommentsSheet(context, baseitem);
          },
        ));
      } else {
        // add icon without functionality, if there is no comment data
        iconButtons.add(Icon(
          Icons.comment,
          color: Colors.grey,
        ));
      }
    }
    // add Maps icon, if it is a Rock
    if (baseitem is Rock) {
      if (baseitem.latitude == 0 || baseitem.longitude == 0) {
        // grey Button if no valid coordinates
        iconButtons.add(
          Icon(
            Icons.map,
            color: Colors.grey,
          ),
        );
      } else {
        iconButtons.add(IconButton(
          icon: Icon(
            Icons.map,
          ),
          onPressed: () async {
            // check if OSMAnd is available - otherwise start google maps or apple Maps
            var preferredMap = MapType.osmand;
            // use OSMAnd+ if available
            final maps = await MapLauncher.installedMaps;
            if (maps.firstWhereOrNull(
                    (element) => element.mapType == MapType.osmandplus) !=
                null) {
              preferredMap = MapType.osmandplus;
            }
            if (!((await MapLauncher.isMapAvailable(MapType.osmandplus) ??
                    false) ||
                (await MapLauncher.isMapAvailable(MapType.osmand) ?? false))) {
              if (Platform.isIOS) {
                preferredMap = MapType.apple;
              } else {
                preferredMap = MapType.google;
              }
            }
            await MapLauncher.showMarker(
              mapType: preferredMap,
              coords: Coords(baseitem.latitude, baseitem.longitude),
              title: baseitem.name,
            );
          },
        ));
      }
    }
    // add other icons
    iconButtons.add(IconButton(
      icon: Icon(Icons.sort_by_alpha),
      onPressed: () {
        sortAlpha = !sortAlpha;
        setState(() {});
      },
    ));
    // add Searchbar Action
    iconButtons.add(searchBar.getSearchAction(context));

    return AppBar(
      title: RichText(
        text: TextSpan(
          text: baseitem.name,
        ),
      ),
      actions: iconButtons,
    );
  }

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
          .where((element) =>
              element.name.toLowerCase().contains(searchBarValue.toLowerCase()))
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
}
