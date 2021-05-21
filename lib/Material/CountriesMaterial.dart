import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Material/BaseItemsMaterial.dart';

class CountryMaterial extends StatefulWidget {
  final BaseItem parentItem;
  CountryMaterial(this.parentItem);
  @override
  _CountryMaterialState createState() => _CountryMaterialState(parentItem);
}

class _CountryMaterialState
    extends BaseItemsMaterialStatefulState<CountryMaterial> {
  final BaseItem parentItem;
  Countries countries;

  _CountryMaterialState(this.parentItem)
      : countries = Countries(parentItem),
        super(parentItem);

  @override
  FutureBuilder futureBuilderListItems(BaseItem parentItem) {
    return FutureBuilder<List<Country>>(
      builder: baseitemsBuilder,
      future: countries.getItems(),
/*      initialData: <Map<String, Object?>>[
        {'gebiet_ID': '1'}
      ],*/
    );
  }

  @override
  FutureOr<int> deleteItems() {
    return countries.deleteItems();
  }

  /// update data from web
  @override
  FutureOr<void> fetchFromWeb() async {
    await countries.updateData();
  }
}
