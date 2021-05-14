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
    return _SubAreasMaterialState(this.parentItem);
  }
}

class _SubAreasMaterialState
    extends BaseItemsMaterialStatefulState<SubAreasMaterial> {
  final Area parentItem;
  late Subareas subareas;

  _SubAreasMaterialState(this.parentItem)
      : subareas = Subareas(parentItem),
        super(parentItem);

  @override
  FutureBuilder itemsBody(BaseItem parentItem) {
    return FutureBuilder(
      builder: baseitemsBuilder,
      future: subareas.getItems(queryItemInt: parentItem.id),
/*      initialData: <Map<String, Object?>>[
        {"gebiet_ID": "1"}
      ],*/
    );
  }

  @override
  List<BaseItem> getItemsData(snapshot) {
    List<Map<String, Object?>> sqlSubareas = snapshot.data;
    return sqlSubareas.map((item) => Subarea.fromSql(item)).toList();
  }

  @override
  FutureOr<int> deleteItems() {
    return subareas.deleteItems(queryItemString: parentItem.name);
  }

  @override
  FutureOr<void> fetchFromWeb() {
    return subareas.fetchFromWeb(parentItem.id.toString());
  }
}
