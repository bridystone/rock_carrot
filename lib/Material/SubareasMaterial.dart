import 'package:flutter/material.dart';

import '../Baseitems/Areas.dart';
import '../Baseitems/Subareas.dart';

class SubAreasMaterial extends StatefulWidget {
  final Area _area;
  SubAreasMaterial(this._area);

  // transfer country to state object
  @override
  _SubAreasMaterialState createState() {
    return _SubAreasMaterialState(this._area);
  }
}

class _SubAreasMaterialState extends State<SubAreasMaterial> {
  final Area _area;
  _SubAreasMaterialState(this._area);

  Subareas _subareas = Subareas();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_area.name),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _subareas.deleteItems(queryItem: _area.areaid.toString());
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(Icons.update),
              onPressed: () async {
//              await _areas.fetchAreas(country);
                //refresh Scaffold
                setState(() {});
              },
            ),
          ],
        ),
        body: Center(child: Text("TODO")));
  }
}
