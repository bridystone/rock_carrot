import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rock_carrot/Baseitems/Areas.dart';
import 'package:rock_carrot/Baseitems/BaseItems.dart';
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Web/Teufelsturm.dart';

class BaseItemTile extends StatefulWidget {
  final BaseItem _baseitem;

  /// function that updates data from the web
  final Function? _updateFunction;
  final Function? _updateAllFunction;
  final Function? _deleteFunction;
  final dynamic _functionParameter;

  /// Constructor
  ///
  /// [updateFunction] Function to update data
  /// [updateAllFunction] Only relevant for update Area!! and SubArea
  /// for Subarea its the link to update TT comments
  /// [functionParameter] id Parameter, to be used in the function
  /// [deleteFunction] -> might be replace by favorites in future
  BaseItemTile(
    this._baseitem, {
    Function? updateFunction,
    Function? updateAllFunction,
    Function? deleteFunction,
    dynamic functionParameter, // might be String or int
  })  : _updateFunction = updateFunction,
        _updateAllFunction = updateAllFunction,
        _deleteFunction = deleteFunction,
        _functionParameter = functionParameter;

  @override
  _BaseItemTileState createState() => _BaseItemTileState(
        _baseitem,
        _updateFunction,
        _updateAllFunction,
        _deleteFunction,
        _functionParameter,
      );
}

class _BaseItemTileState extends State<BaseItemTile> {
  final BaseItem _baseitem;
  final Function? _updateFunction;
  final Function? _updateAllFunction;
  final Function? _deleteFunction;
  final dynamic _functionParameter; //might be String or int

  _BaseItemTileState(
    this._baseitem,
    this._updateFunction,
    this._updateAllFunction,
    this._deleteFunction,
    this._functionParameter,
  );

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
    // Add UpdateAll possibility (ony if baseitem is Area)
    if (_updateAllFunction != null && _baseitem is Area) {
      secondarySlideActions.add(IconSlideAction(
        caption: 'Update All',
        color: Colors.greenAccent,
        icon: Icons.system_update_rounded,
        onTap: () async {
          // clear number for update
          setState(() {
            _baseitem.setChildCountStatus(ChildCountStatus.update_in_progress);
          });

          // first perform update of area
          // otherwise the caching of data will result in 0 values
          // TODO: doesn't seem to work - caching fails if no update was done before
          final records = await _updateFunction!(_functionParameter) as int;
          // perform actual Scraping
          await _updateAllFunction!(_functionParameter) as int;

          // set Results
          setState(() {
            _baseitem.updateChildCount(records);
          });
        },
      ));
    }
    // Add UpdateTT Comments possibility (ony if baseitem is Subarea & in Sächsische Schweiz)
    if (_updateAllFunction != null &&
        _baseitem is Subarea &&
        sandsteinNameTeufelsturmAreaIdMap.keys.contains(_baseitem.name)) {
      secondarySlideActions.add(IconSlideAction(
        caption: 'Scrape TT',
        color: Colors.greenAccent,
        icon: Icons.cloud_download,
        onTap: () async {
          setState(() {
            _baseitem.setChildCountStatus(ChildCountStatus.update_in_progress);
          });
          // TODO: show Modal Dialog
          // clear number for update
          final records = await _updateAllFunction!(
              sandsteinNameTeufelsturmAreaIdMap[_baseitem.name]) as int;
          // set Results
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
    return ListTile(
      title: 
        _baseitem.nr != 0 ? // if there is a reference number for the rock
        Text(_baseitem.nr.toString() + ' ' + _baseitem.name) : //concat number and name
        Text(_baseitem.name), // else show only name
      subtitle: _baseitem.nameCZ != '2nd Language Name' ? Text(_baseitem.nameCZ) : null, //if second language set, show it, else don't
      trailing: Text(_baseitem.childCount), 
    );
  }    
}