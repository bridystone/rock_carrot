import 'package:flutter/cupertino.dart';

/// the basic country item -> direct relation to land in database
enum ChildCountStatus {
  empty,
  update_in_progress,
}

class BaseItem {
  String? name;
  double? nr;
  int childCountInt;
  int? commentCountInt;
  String? commentCount;
  BaseItem(
      {this.name,
      this.nr,
      // ignore: invalid_required_named_param
      @required this.childCountInt = 0,
      this.commentCountInt});

  // Child element Getter + Update functions
  String get childCount {
    // state -1 == update in progress
    if (childCountInt == -1) {
      return 'updating';
    }
    if (childCountInt == 0) {
      return 'N/A';
    }
    return childCountInt.toString();
  }

  void updateChildCount(int newValue) {
    childCountInt = newValue;
  }

  void setChildCountStatus(ChildCountStatus status) {
    if (status == ChildCountStatus.empty) childCountInt = 0;
    if (status == ChildCountStatus.update_in_progress) childCountInt = -1;
  }
}

class BaseItems {
  /// sorting method Name ASC
  int sortByName(BaseItem item_a, BaseItem item_b) {
    return item_a.name!.compareTo(item_b.name!);
  }

  /// sorting method Count DESC
  int sortByChildsDesc(BaseItem item_a, BaseItem item_b) {
    // explicitely use private integer!
    return item_b.childCountInt.compareTo(item_a.childCountInt);
  }
}
