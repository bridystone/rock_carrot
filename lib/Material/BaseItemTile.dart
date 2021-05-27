import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';

class BaseItemTile extends StatefulWidget {
  final BaseItem _baseitem;

  /// function that updates data from the web
  final Function? _updateFunction;
  final Function? _deleteFunction;
  final dynamic _functionParameter;

  BaseItemTile(
    this._baseitem, {
    Function? updateFunction,
    Function? deleteFunction,
    dynamic functionParameter, // might be String or int
  })  : _updateFunction = updateFunction,
        _deleteFunction = deleteFunction,
        _functionParameter = functionParameter;

  @override
  _BaseItemTileState createState() => _BaseItemTileState(
        _baseitem,
        _updateFunction,
        _deleteFunction,
        _functionParameter,
      );
}

class _BaseItemTileState extends State<BaseItemTile> {
  final BaseItem _baseitem;
  final Function? _updateFunction;
  final Function? _deleteFunction;
  final dynamic _functionParameter; //might be String or int

  _BaseItemTileState(this._baseitem, this._updateFunction, this._deleteFunction,
      this._functionParameter);

  @override
  Widget build(BuildContext context) {
    return _customCountryTileSlide(context);
  }

  Widget _customCountryTileSlide(BuildContext context) {
    List<Widget>? primarySlideActions = [];
    List<Widget>? secondarySlideActions = [];
    // implement update /delete is supplied
    if (_updateFunction != null) {
      secondarySlideActions.add(IconSlideAction(
        caption: 'Update',
        color: Colors.green,
        icon: Icons.update,
        onTap: () async {
          setState(() {
            _baseitem.setChildCountStatus(ChildCountStatus.update_in_progress);
          });

          final records = await _updateFunction!(_functionParameter) as int;

          setState(() {
            _baseitem.updateChildCount(records);
          });
        },
      ));
    }
    if (_deleteFunction != null) {
      primarySlideActions.add(IconSlideAction(
        caption: 'Delete',
        color: Colors.red,
        icon: Icons.delete,
        onTap: () async {
          await _deleteFunction!(_functionParameter);

          setState(() {
            _baseitem.setChildCountStatus(ChildCountStatus.empty);
          });
        },
      ));
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: primarySlideActions,
      secondaryActions: secondarySlideActions,
      child: _customBaseItemTileTap(context),
    );
  }

  /// makeing the custom tile tapable
  Widget _customBaseItemTileTap(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/' + _baseitem.runtimeType.toString(),
          arguments: _baseitem, // parent item
        ).then((value) {
          // refresh current page after back button is pushed to ensure new data is taken care of
          // TODO: NOTIFY parent, if data was updated
          // TODO: Notify dedicated child to update / first update the data and do notification
          //setState(() {});
        });
      },
      child: _customBaseItemTileContent(context),
    );
  }

  /// the actual Content of the Tile
  Widget _customBaseItemTileContent(BuildContext context) {
    /// add nr to tile, if available
    Widget nameWidget;
    if (_baseitem.nr != 0) {
      nameWidget = Row(children: [
        Padding(
          padding: EdgeInsets.only(right: 5.0),
          child: Text(_baseitem.nr.toString()),
        ),
        Text(_baseitem.name),
      ]);
    } else {
      nameWidget = Text(_baseitem.name);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(top: 1.0, bottom: 1.0),
            child: nameWidget,
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Text(_baseitem.childCount),
          )
        ],
      ),
    );
  }
}
