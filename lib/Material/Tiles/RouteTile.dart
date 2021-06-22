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
        title: ListTile(
          //Title of ExpansionTile is a ListTile
          title: Text.rich(
            // use rich text to combine Text and Icon and NOT overflow on long route names
            TextSpan(
              children: [
                TextSpan(
                  text: _route.nr.toString() + ' ' + _route.name,
                ),
                WidgetSpan(
                  child: (_route.commentCountInt! > 0)
                      ? Icon(
                          Icons.comment,
                          size: 15,
                        )
                      : Container(),
                ),
              ],
            ),
          ),

          subtitle: _route.nameCZ != '2nd Language Name'
              ? Text(_route.nameCZ)
              : null, //show czech name if available
          trailing: Text(_route.grade), //show grade
        ),
        children: [
          ListTile(
            trailing: Text(
              _route.rings,
              style: TextStyle(fontSize: 10),
            ),
            title: Text(
              _route.climbingStyle != ''
                  ? _route.climbingStyle + '\n' + _route.description
                  : _route.description,
              style: TextStyle(fontSize: 12),
            ),
            subtitle: Text(
              // concat string for first ascent
              _route.firstAscentLead +
                  (_route.firstAscentLead != '' ? ', ' : '') +
                  _route.firstAscentPartners +
                  (_route.firstAscentPartners != '' ? ', ' : '') +
                  _route.firstAscentDate,
              style: TextStyle(fontSize: 12),
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
