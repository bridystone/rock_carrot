import 'package:flutter/material.dart';

class SubAreasMaterial extends StatefulWidget {
  final String area;
  SubAreasMaterial(this.area);

  // transfer country to state object
  @override
  _SubAreasMaterialState createState() {
    return _SubAreasMaterialState(this.area);
  }
}

class _SubAreasMaterialState extends State<SubAreasMaterial> {
  final String area;
  _SubAreasMaterialState(this.area);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(area),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
//              _areas.deleteAreas(country);
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
