import 'dart:async';

import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Database/sql.dart';

abstract class BaseItems {
  BaseItem parent;
  BaseItems(this.parent);

  /// list of elements in this Object
  List<BaseItem> elements = [];

  /// this name is used for checking if this is a legitimate delete/insert for Routes/Comments
  static const dummyName = '__DUMMY__NAME__';

  SqlHandler sqlHelper = SqlHandler();

  /// get the items from the database
  Future<List<BaseItem>> getItems();
}
