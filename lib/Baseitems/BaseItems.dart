import 'dart:async';

import 'package:yacguide_flutter/Baseitems/BaseItem.dart';
import 'package:yacguide_flutter/Database/sql.dart';

abstract class BaseItems {
  // TODO: get rid of parent in this class use specific parents in subclasses
  BaseItem parent = BaseItem(0, '', 0);
  BaseItems([BaseItem? parent_parameter]) {
    parent = parent_parameter ?? BaseItem(0, '', 0);
  }

  /// list of elements in this Object
  List<BaseItem> elements = [];

  /// this name is used for checking if this is a legitimate delete/insert for Routes/Comments
  static const dummyName = '__DUMMY__NAME__';

  SqlHandler sqlHelper = SqlHandler();

  /// get the items from the database
  Future<List<BaseItem>> getItems();
}
