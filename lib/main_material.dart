import 'package:flutter/material.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Material/AreasMaterial.dart';
import 'package:yacguide_flutter/Material/SubareasMaterial.dart';
import 'package:yacguide_flutter/Material/CountriesMaterial.dart';

class YacGuideFlutterMaterial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // create Material
    return MaterialApp(
      title: 'YacGuideFlutter',
      home: CountryMaterial(BaseItem(-1, "Countries", -1)),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            final BaseItem base = settings.arguments as BaseItem;
            return MaterialPageRoute(
                builder: (context) => CountryMaterial(base));
          case '/Country':
            final Country country = settings.arguments as Country;
            return MaterialPageRoute(
                builder: (context) => AreasMaterial(country));
          case '/Area':
            final Area area = settings.arguments as Area;
            return MaterialPageRoute(
                builder: (context) => SubAreasMaterial(area));
          default:
        }
      },
    );
  }
}
