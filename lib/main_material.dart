import 'package:flutter/material.dart';
import 'package:rock_carrot/Baseitems/Areas.dart';
import 'package:rock_carrot/Baseitems/Countries.dart';
import 'package:rock_carrot/Baseitems/Rocks.dart';
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Material/AreasMaterial.dart';
import 'package:rock_carrot/Material/SubareasMaterial.dart';
import 'package:rock_carrot/Material/CountriesMaterial.dart';
import 'package:rock_carrot/Material/RocksMaterial.dart';
import 'package:rock_carrot/Material/RoutesMaterial.dart';

class RockCarrotMaterial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // create Material
    return MaterialApp(
      title: 'Rock Carrot',
      home: CountryMaterial(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute<CountryMaterial>(
                builder: (context) => CountryMaterial());
          case '/Country':
            final country = settings.arguments as Country;
            return MaterialPageRoute<AreasMaterial>(
                builder: (context) => AreasMaterial(country));
          case '/Area':
            final area = settings.arguments as Area;
            return MaterialPageRoute<SubAreasMaterial>(
                builder: (context) => SubAreasMaterial(area));
          case '/Subarea':
            final subarea = settings.arguments as Subarea;
            return MaterialPageRoute<RocksMaterial>(
                builder: (context) => RocksMaterial(subarea));
          case '/Rock':
            final rock = settings.arguments as Rock;
            return MaterialPageRoute<RoutesMaterial>(
                builder: (context) => RoutesMaterial(rock));
          default:
        }
      },
    );
  }
}
