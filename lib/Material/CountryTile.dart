import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';

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
    return _customCountryTileSlide(context, _country);
  }

  Widget _customCountryTileSlide(BuildContext context, Country country) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Update',
          color: Colors.green,
          icon: Icons.update,
          onTap: () async {
            final records = await Areas(country).updateData();

            setState(() {
              country.areaCount = records;
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
            await Areas(country).deleteItems();

            setState(() {
              country.areaCount = 0;
            });
          },
        )
      ],
      child: _customCountryTileTap(context, country),
    );
  }

  /// makeing the custom tile tapable
  Widget _customCountryTileTap(BuildContext context, Country country) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/' + country.runtimeType.toString(),
          arguments: country, // parent item
        ).then((value) {
          // refresh current page after back button is pushed to ensure new data is taken care of
          // TODO: NOTIFY parent, if data was updated
          // TODO: Notify dedicated child to update / first update the data and do notification
          //setState(() {});
        });
      },
      child: _customCountryTileContent(context, country),
    );
  }

  /// the actual Content of the Tile
  Widget _customCountryTileContent(BuildContext context, Country country) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(top: 1.0, bottom: 1.0),
            child: Text(country.land),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Text(country.areaCount.toString()),
          )
        ],
      ),
    );
  }
}
