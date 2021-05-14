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
    return _AreasMaterialState(this.parentItem);
  }
}

class _AreasMaterialState
    extends BaseItemsMaterialStatefulState<AreasMaterial> {
  final Country parentItem;
  late Areas areas;

  _AreasMaterialState(this.parentItem)
      : areas = Areas(parentItem),
        super(parentItem);

  @override
  FutureBuilder itemsBody(BaseItem parentItem) {
    return FutureBuilder(
      builder: baseitemsBuilder,
      future: areas.getItems(queryItemString: parentItem.name),
      initialData: <Map<String, Object?>>[
        {"gebiet_ID": "1"}
      ],
    );
  }

  @override
  List<BaseItem> getItemsData(snapshot) {
    List<Map<String, Object?>> sqlAreas = snapshot.data;
    return sqlAreas.map((item) => Area.fromSql(item)).toList();
  }

  @override
  FutureOr<int> deleteItems() {
    return areas.deleteItems(queryItemString: parentItem.name);
  }

  @override
  FutureOr<void> fetchFromWeb() {
    return areas.fetchFromWeb(parentItem.name);
  }
}
