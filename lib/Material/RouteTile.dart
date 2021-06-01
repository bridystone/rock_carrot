import 'package:flutter/material.dart' hide Route;
import 'package:rock_carrot/Baseitems/Routes.dart';
import 'package:rock_carrot/Material/CommentsSheet.dart';

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
        title: ListTile( //Title of ExpansionTile is a ListTile
          title: Row(
            children: [
              Text(_route.nr.toString()+ ' ' + _route.name),
              (_route.commentCountInt! > 0) ? // if comment in database, show comment icon
                Icon(
                  Icons.comment,
                  size: 15,
                  ) :
                Container (),
            ],            
          ),
          subtitle: _route.nameCZ != '2nd Language Name' ? Text(_route.nameCZ) : null, //show czech name if available
          trailing: Text(_route.grade), //show grade
        ),  
        children: [
          ListTile(
            trailing: Text(
              _route.rings,
              style: TextStyle(fontSize: 10),
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
                Expanded(
                  child: Column(
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
                ),
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
