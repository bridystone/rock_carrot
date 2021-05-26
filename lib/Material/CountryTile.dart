import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Web/Sandstein.dart';
import 'package:yacguide_flutter/Web/SandsteinSql.dart';

class CountryTile extends StatefulWidget {
  final Country _country;

  CountryTile(this._country);

  @override
  _CountryTileState createState() => _CountryTileState(_country);
}

class _CountryTileState extends State<CountryTile> {
  final Country _country;

  _CountryTileState(this._country);

  @override
  Widget build(BuildContext context) {
    return _customCountryTileSlide(context);
  }

/*
  Widget _customCountryTileDismissible(BuildContext context) {
    return Dismissible(
      key: Key(_country.land),
      confirmDismiss: (DismissDirection dir) => Future.value(true),
      onDismissed: (DismissDirection dir) async {
        print('dismissed');
        if (dir == DismissDirection.endToStart) {
          setState(() {
            _country.setAreaCountStatus(AreaCountStatus.update_in_progress);
          });
          final records = await Sandstein().updateAreas(_country.land);

          setState(() {
            _country.updateAreaCount(records);
          });
        } else {
          await Sandstein().deleteAreasFromDatabase(_country.land);

          setState(() {
            _country.setAreaCountStatus(AreaCountStatus.empty);
          });
        }
      },
      background: buildSwipeActionLeft(),
      secondaryBackground: buildSwipeActionRight(),
      child: _customCountryTileTap(context),
    );
  }

  Widget buildSwipeActionLeft() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.green,
      child: Icon(Icons.update, color: Colors.white, size: 32),
    );
  }

  Widget buildSwipeActionRight() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.red,
      child: Icon(Icons.delete_forever, color: Colors.white, size: 32),
    );
  }
*/
  Widget _customCountryTileSlide(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Update',
          color: Colors.green,
          icon: Icons.update,
          onTap: () async {
            setState(() {
              _country.setAreaCountStatus(AreaCountStatus.update_in_progress);
            });

            final records = await Sandstein().updateAreas(_country.land);

            setState(() {
              _country.updateAreaCount(records);
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
            await Sandstein().deleteAreasFromDatabase(_country.land);

            setState(() {
              _country.setAreaCountStatus(AreaCountStatus.empty);
            });
          },
        )
      ],
      child: _customCountryTileTap(context),
    );
  }

  /// makeing the custom tile tapable
  Widget _customCountryTileTap(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/' + _country.runtimeType.toString(),
          arguments: _country, // parent item
        ).then((value) {
          // refresh current page after back button is pushed to ensure new data is taken care of
          // TODO: NOTIFY parent, if data was updated
          // TODO: Notify dedicated child to update / first update the data and do notification
          //setState(() {});
        });
      },
      child: _customCountryTileContent(context),
    );
  }

  /// the actual Content of the Tile
  Widget _customCountryTileContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(top: 1.0, bottom: 1.0),
            child: Text(_country.land),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Text(_country.areaCount.toString()),
          )
        ],
      ),
    );
  }
}
