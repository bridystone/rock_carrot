import 'package:flutter/material.dart';
import 'package:rock_carrot/Baseitems/Rocks.dart';

class RockTile extends StatefulWidget {
  final Rock _rock;
  RockTile(this._rock);
  @override
  _RockTileState createState() => _RockTileState(_rock);
}

class _RockTileState extends State<RockTile> {
  final Rock _rock;
  _RockTileState(this._rock);

  @override
  Widget build(BuildContext context) {
    if (_rock.nr == 9999 || _rock.nr == 9998){ //don't show special places like parking lots etc.
      return Container();
    }
    return Column(children: [
      ListTile(
        tileColor: (_rock.status == '[X]' || _rock.status == '[E]') ? Colors.grey : null, // grey backgroud color for prohibited or collapsed peaks
        title: 
        _rock.nr != 0 ? // if there is a reference number for the rock
        Text(_rock.nr.toString() + ' ' + _rock.name + // number and rock name
              (_rock.type != '[G]' ?  ' ' + _rock.type : '') + // if it's anything else than natural a peak, ie cliff or boulder, show type
              (_rock.status != '[]' ? ' ' + _rock.status : '') // show status if non-empty, X,Z,T,E
              ) : //concat number and name
        Text(_rock.name), // else show only name
        subtitle: _rock.nameCZ != '2nd Language Name' ? Text(_rock.nameCZ) : null, //if second language set, show it, else don't
        trailing: Text(_rock.childCount),
        onTap: () {
          Navigator.pushNamed( //navigate to Routes
            context,
            '/' + _rock.runtimeType.toString(),
            arguments: _rock,
          );
        }, 
      ),
      Divider(
        height: 1,
        thickness: 1,
      ),
    ]);
  }
}
