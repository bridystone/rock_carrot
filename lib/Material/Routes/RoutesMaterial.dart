import 'package:flutter/material.dart' hide Route;
import 'package:rock_carrot/Baseitems/BaseItems.dart';
import 'package:rock_carrot/Baseitems/Rocks.dart';
import 'package:rock_carrot/Baseitems/Routes.dart';
import 'package:rock_carrot/Material/Routes/BaseMaterial.dart';
import 'package:rock_carrot/Material/Tiles/RouteTile.dart';

class RoutesMaterial extends StatefulWidget {
  final Rock parentItem;

  // List of all routes - to be accessible for later
  RoutesMaterial(this.parentItem);

  // transfer country to state object
  @override
  _RoutesMaterialState createState() {
    return _RoutesMaterialState(parentItem);
  }
}

class _RoutesMaterialState
    extends BaseItemsMaterialStatefulState<RoutesMaterial> with BaseItems {
  final Routes _routes;

  _RoutesMaterialState(Rock rock) : _routes = Routes(rock) {
    searchBar = initializeSearchBar(_routes.parentRock);
    // default sorting ist by number
    sortAlpha = false;
  }

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: FutureBuilder<List<Route>>(
        builder: futureBuildItemList,
        future: _routes.getRoutes(),
      ),
    );
  }

  @override
  Widget buildItemList(AsyncSnapshot snapshot) {
    // store snapshot data in local list
    baseitem_list = snapshot.data;

    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: baseitem_list.length,
      itemBuilder: (context, i) {
        final route = baseitem_list[i] as Route;
        return RouteTile(route);
      },
    );
  }
}
