import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Material/BaseItemsMaterial.dart';

class SubAreasMaterial extends StatefulWidget {
  final Area parentItem;
  SubAreasMaterial(this.parentItem);

  // transfer country to state object
  @override
  _SubAreasMaterialState createState() {
    return _SubAreasMaterialState(parentItem);
  }
}

class _SubAreasMaterialState
    extends BaseItemsMaterialStatefulState<SubAreasMaterial> {
  final Area parentItem;
  Subareas subareas;

  _SubAreasMaterialState(this.parentItem)
      : subareas = Subareas(parentItem),
        super(parentItem);

  @override
  FutureBuilder futureBuilderListItems(BaseItem parentItem) {
    return FutureBuilder<List<Subarea>>(
      builder: baseitemsBuilder,
      future: subareas.getItems(),
/*      initialData: <Map<String, Object?>>[
        {'gebiet_ID': '1'}
      ],*/
    );
  }

  @override
  FutureOr<int> deleteItems() {
    return subareas.deleteItems();
  }

  @override
  FutureOr<void> fetchFromWeb() {
    return subareas.fetchFromWeb();
  }
}
