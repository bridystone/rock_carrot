import 'package:flutter/material.dart';

class AreaMaterial extends StatefulWidget {
  final String country;
  AreaMaterial(this.country);

  @override
  _AreaMaterialState createState() {
    return _AreaMaterialState(this.country);
  }
}

class _AreaMaterialState extends State<AreaMaterial> {
  final String country;
  _AreaMaterialState(this.country);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(country),
      ),
    );
  }
}
