import 'package:flutter/material.dart' hide Route;
import 'package:yacguide_flutter/Baseitems/Routes.dart';

class RouteTile extends StatefulWidget {
  final Route _route;
  RouteTile(this._route);
  @override
  _RouteTileState createState() => _RouteTileState(_route);
}

class _RouteTileState extends State<RouteTile> {
  final Route _route;
  _RouteTileState(this._route);

  @override
  Widget build(BuildContext context) {
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
              child: Text(_route.nr.toString()),
            ),
            Text(_route.name),
          ],
        ),

        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_route.grade),
            Text(_route.climbingStyle),
          ],
        ),
        key: Key(_route.name),
        //trailing: Text('(' + items[i].childCount.toString() + ')'),
        children: [
          ListTile(
            trailing: Column(
              children: [
                Transform.rotate(
                  angle: 90 * 3.1416 / 180,
                  child: Text(_route.rings),
                )
              ],
            ),
            title: Text(_route.description),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text(
                    _route.firstAscentDate,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_route.firstAscentLead),
                    Text(_route.firstAscentPartners),
                  ],
                )
              ],
            ), /*
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
                      //future: routes.getRouteComments(route.wegId),
                      builder: routeInformationBuilder,
                    );
                  });
            },*/
          )
        ],
      ),
      Divider(
        thickness: 4,
      )
    ]);
  }
}
