import 'package:flutter/material.dart';
import 'dart:async';

import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Material/BaseItemsMaterial.dart';

class AreasMaterial extends StatefulWidget {
  final Country parentItem;
  AreasMaterial(this.parentItem);

  // transfer country to state object
  @override
  _AreasMaterialState createState() {
    return _AreasMaterialState(parentItem);
  }
}

class _AreasMaterialState
    extends BaseItemsMaterialStatefulState<AreasMaterial> {
  Country parentItem;
  Areas areas;

  _AreasMaterialState(Country country)
      : parentItem = country,
        areas = Areas(country),
        super(BaseItem(0, country.land, 0));

  @override
  FutureBuilder futureBuilderListItems(BaseItem parentItem) {
    return FutureBuilder<List<Area>>(
      builder: baseitemsBuilder,
      future: areas.getItems(),
    );
  }

  @override
  FutureOr<int> deleteItems() {
    return areas.deleteItems();
  }

  @override
  FutureOr<void> fetchFromWeb() {
    return areas.updateData();
  }
}
