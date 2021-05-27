import 'dart:ui';

import 'package:flutter/material.dart' hide Route;
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Baseitems/Routes.dart';
import 'package:yacguide_flutter/Material/BaseMaterial.dart';
import 'package:yacguide_flutter/Material/RouteTile.dart';

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
    searchBar = initializeSearchBar(_routes.parentRock.name);
    // default sorting ist by number
    sortAlpha = false;
  }

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      // enable Refresh data with pulldown
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

  List<Route> getCommentsFromSnapshot(AsyncSnapshot snapshot) {
    List<Map<String, Object?>> sqlRoutes = snapshot.data;
    return sqlRoutes.map((item) => Route.fromSql(item)).toList();
  }

  Widget routeInformationBuilder(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      List<Comment> comments = snapshot.data;
      return buildModalComments(comments);
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  /// actual design of the Modal dialog
  ///
  /// if no data is available - it shows: no data
  /// otherwise multiple comments are shown
  Widget buildModalComments(List<Comment> comments) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: comments.isEmpty
            // no comments available
            ? Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text('no comments available'),
                ))
            // enumerate all comments
            : SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  // iterating through all available comments
                  children: comments.map((comment) {
                    return Column(children: [
                      // status row top
                      Row(children: [
                        Text(
                          comment.datum.substring(0, 10) +
                              ' UID:' +
                              comment.userid.toString(),
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                      // actual comment
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          comment.kommentar,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      // statusrow bottom
                      Column(children: [
                        Row(children: [
                          Text('qual:' + comment.qual),
                          Icon(Icons.thumb_up),
                          Text(' | sicher:' + comment.sicher),
                          Text(' | nass:' + comment.nass),
                        ]),
                        Row(
                          children: [
                            Text('schwer:' + comment.schwer),
                            Text(' | geklettert:' + comment.geklettert),
                            Text(' | begehung:' + comment.begehung),
                          ],
                        )
                      ]),
                    ]);
                  }).toList(),
                ),
              ));
  }
}
