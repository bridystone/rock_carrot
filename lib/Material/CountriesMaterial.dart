import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Baseitems/Countries.dart';
import 'package:yacguide_flutter/Material/BaseItemsMaterial.dart';

class CountryMaterial extends StatefulWidget {
  final BaseItem parentItem;
  CountryMaterial(this.parentItem);
  @override
  _CountryMaterialState createState() => _CountryMaterialState(this.parentItem);
}

class _CountryMaterialState
    extends BaseItemsMaterialStatefulState<CountryMaterial> {
  final BaseItem parentItem;
  Countries countries;

  _CountryMaterialState(this.parentItem)
      : countries = Countries(parentItem),
        super(parentItem);

  @override
  FutureBuilder itemsBody(BaseItem parentItem) {
    return FutureBuilder(
      builder: baseitemsBuilder,
      future: countries.getItems(),
/*      initialData: <Map<String, Object?>>[
        {"gebiet_ID": "1"}
      ],*/
    );
  }

  @override
  List<BaseItem> getItemsData(snapshot) {
    List<Map<String, Object?>> sqlCountries = snapshot.data;
    return sqlCountries.map((item) => Country.fromSql(item)).toList();
  }

  @override
  FutureOr<int> deleteItems() {
    return countries.deleteItems();
  }

  @override
  FutureOr<void> fetchFromWeb() {
    return countries.fetchFromWeb("");
  }
}
