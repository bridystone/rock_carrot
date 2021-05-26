import 'dart:ui';

import 'package:flutter/material.dart' hide Route;
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Baseitems/Routes.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Material/FuturesHelper.dart';

class RoutesMaterial extends StatefulWidget {
  final Rock parentRock;
  final Subarea parentSubarea;

  // List of all routes - to be accessible for later
  RoutesMaterial(this.parentSubarea, this.parentRock);

  // transfer country to state object
  @override
  _RoutesMaterialState createState() {
    return _RoutesMaterialState(parentSubarea, parentRock);
  }
}

class _RoutesMaterialState extends State<RoutesMaterial> with FuturesHelper {
  final Routes routes;

  _RoutesMaterialState(Subarea subarea, Rock rock)
      : routes = Routes(subarea, rock);

  /// build the Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: generateAppbar(routes.parentRock.gipfelName, true, true),
      body: futureBuilderListItems(),
    );
  }

  /// generate appbar
  AppBar generateAppbar(String title, bool buttonDelete, bool buttonUpdate) {
    return AppBar(
      title: Text(title),
    );
  }

  FutureBuilder futureBuilderListItems() {
    return FutureBuilder<List<Route>>(
      builder: futureBuilderRoutes,
      future: routes.getRoutes(),
/*      initialData: <Map<String, Object?>>[
        {'gebiet_ID': '1'}
      ],*/
    );
  }

  Widget futureBuilderRoutes(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      // push data into protected storage
      routes.routes = snapshot.data;
      return buildListRoutes();
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  Widget buildListRoutes() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: routes.routes.length,
      itemBuilder: (context, i) {
        final route = routes.routes[i];
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
                          //future: routes.getComments(route),
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
