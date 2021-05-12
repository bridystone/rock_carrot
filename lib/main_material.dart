import 'package:flutter/material.dart';
import 'country_material.dart';

class YacGuideFlutterMaterial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // create Material
    return MaterialApp(
      title: 'YacGuideFlutter',
      home: CountryMaterial(),
    );
  }
}
