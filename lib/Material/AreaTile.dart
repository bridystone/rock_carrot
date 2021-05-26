import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';
import 'package:yacguide_flutter/Web/SandsteinSql.dart';

class AreaTile extends StatefulWidget {
  final Area _area;

  AreaTile(this._area);

  @override
  _AreaTileState createState() => _AreaTileState(_area);
}

class _AreaTileState extends State<AreaTile> {
  final Area _area;

  _AreaTileState(this._area);

  // TODO: Create Custom Stateful Widget
  @override
  Widget build(BuildContext context) {
    return _customAreaTileSlide(context);
  }

  Widget _customAreaTileSlide(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Update',
          color: Colors.green,
          icon: Icons.update,
          onTap: () async {
            setState(() {
              _area.setChildCountStatus(ChildCountStatus.update_in_progress);
            });

            final records =
                await Sandstein().updateSubareasInclComments(_area.areaId);

            setState(() {
              _area.updateChildCount(records);
            });
          },
        )
      ],
      actions: [
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () async {
            await Sandstein().deleteSubareasFromDatabase(_area.areaId);

            setState(() {
              _area.setChildCountStatus(ChildCountStatus.empty);
            });
          },
        )
      ],
      child: _customAreaTileTap(context),
    );
  }

  Widget _customAreaTileTap(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/' + _area.runtimeType.toString(),
          arguments: _area, // parent item
        ).then((value) {
          // refresh current page after back button is pushed to ensure new data is taken care of
          // TODO: NOTIFY parent, if data was updated
          // TODO: Notify dedicated child to update / first update the data and do notification
          //setState(() {});
        });
      },
      child: _customAreaTileContent(context),
    );
  }

  /// the actual Content of the Tile
  Widget _customAreaTileContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(top: 1.0, bottom: 1.0),
            child: Text(_area.name),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Text(_area.childCount),
          )
        ],
      ),
    );
  }
}
