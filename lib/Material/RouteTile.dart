import 'package:flutter/material.dart' hide Route;
import 'package:yacguide_flutter/Baseitems/Routes.dart';
import 'package:yacguide_flutter/Material/CommentsSheet.dart';

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
        tilePadding: EdgeInsets.only(left: 5),
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
              padding: EdgeInsets.only(right: 7.0),
              child: Text(
                _route.nr.toString(),
                style: TextStyle(fontSize: 13),
              ),
            ),
            Text(
              _route.name,
              style: TextStyle(fontSize: 14),
            ),
            (_route.commentCountInt! > 0)
                ? Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Icon(
                      Icons.comment,
                      size: 15,
                    ))
                : Container(),
          ],
        ),

        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _route.grade,
              style: TextStyle(fontSize: 13),
            ),
            Text(
              _route.climbingStyle,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        key: Key(_route.name),
        //trailing: Text('(' + items[i].childCount.toString() + ')'),
        children: [
          ListTile(
            trailing: Column(
              children: [
                Transform.rotate(
                  angle: 00 * 3.1416 / 180,
                  child: Text(
                    _route.rings,
                    style: TextStyle(fontSize: 10),
                  ),
                )
              ],
            ),
            title: Text(
              _route.description,
              style: TextStyle(fontSize: 12),
            ),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text(
                    _route.firstAscentDate,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _route.firstAscentLead,
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      _route.firstAscentPartners,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
            onTap: () {
              CommentsSheet().showCommentsSheet(context, _route);
            },
          )
        ],
      ),
      Divider(
        height: 1,
        thickness: 1,
      )
    ]);
  }
}
