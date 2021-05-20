import 'dart:ui';

import 'package:flutter/material.dart' hide Route;
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Baseitems/Routes.dart';
import 'package:yacguide_flutter/Material/BaseItemsMaterial.dart';

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
    extends BaseItemsMaterialStatefulState<RoutesMaterial> {
  final Rock _parentItem;
  final Routes _routes;
  Comments comments;

  _RoutesMaterialState(this._parentItem)
      : _routes = Routes(_parentItem),
        comments = Comments(_parentItem),
        super(_parentItem);

  @override
  FutureBuilder futureBuilderListItems(BaseItem parentItem) {
    return FutureBuilder<List<Map<String, Object?>>>(
      builder: baseitemsBuilder,
      future: _routes.getItems(queryItemInt: _parentItem.gipfelId),
/*      initialData: <Map<String, Object?>>[
        {'gebiet_ID': '1'}
      ],*/
    );
  }

  @override
  Widget baseitemsBuilder(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      final items = getItemsData(snapshot);
      return buildListRoutes(
          items); // use Routesbuilder instead of baseitembuilder
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  Widget buildListRoutes(List<Route> routes) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: routes.length,
      itemBuilder: (context, i) {
        final route = routes[i];
        return Column(children: [
          ExpansionTile(
            /*
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ,
              ],
            ),*/
            title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text(route.wegnr),
                ),
                Text(route.wegname == '' ? route.wegnameCZ : route.wegname),
              ],
            ),

            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(route.schwierigkeit),
                Text(route.kletterei == '' ? '' : '[${route.kletterei}]'),
              ],
            ),
            key: Key(i.toString()),
            //trailing: Text('(' + items[i].childCount.toString() + ')'),
            children: [
              ListTile(
                trailing: Column(
                  children: [
                    Transform.rotate(
                      angle: 90 * 3.1416 / 180,
                      child: Text('Ringe:${route.ringzahl}'),
                    )
                  ],
                ),
                title: Text(
                  (route.wegbeschr == '') ? route.wegbeschrCZ : route.wegbeschr,
                ),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 5.0),
                      child: Text(
                        route.erstbegdatum.substring(0, 4),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route.erstbegvorstieg),
                        Text(route.erstbegnachstieg),
                      ],
                    )
                  ],
                ),
                onTap: () {
                  // TODO: WHY <void> ???
                  showModalBottomSheet<void>(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return FutureBuilder<List<Comment>>(
                          future: _routes.getComments(route),
                          builder: routeInformationBuilder,
                        );
                      });
                },
              )
            ],
          ),
          Divider(
            thickness: 4,
          )
        ]);
      },
    );
  }

  @override
  List<Route> getItemsData(snapshot) {
    List<Map<String, Object?>> sqlRoutes = snapshot.data;
    return sqlRoutes.map((item) => Route.fromSql(item)).toList();
  }

  @override
  FutureOr<int> deleteItems() {
    return _routes.deleteItems();
  }

  @override
  FutureOr<void> fetchFromWeb() {
    return _routes.fetchFromWeb();
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
