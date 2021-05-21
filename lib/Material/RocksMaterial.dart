import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Material/BaseItemsMaterial.dart';

class RocksMaterial extends StatefulWidget {
  final Subarea parentItem;
  RocksMaterial(this.parentItem);

  // transfer country to state object
  @override
  _RocksMaterialState createState() {
    return _RocksMaterialState(parentItem);
  }
}

class _RocksMaterialState
    extends BaseItemsMaterialStatefulState<RocksMaterial> {
  final Subarea parentItem;
  Rocks rocks;

  _RocksMaterialState(this.parentItem)
      : rocks = Rocks(parentItem),
        super(parentItem);

  @override
  FutureBuilder futureBuilderListItems(BaseItem parentItem) {
    return FutureBuilder<List<Rock>>(
      builder: baseitemsBuilder,
      future: rocks.getItems(),
/*      initialData: <Map<String, Object?>>[
        {'gebiet_ID': '1'}
      ],*/
    );
  }

  @override
  FutureOr<int> deleteItems() {
    return rocks.deleteItems();
  }

  @override
  FutureOr<void> fetchFromWeb() {
    return rocks.fetchFromWeb();
  }
}
