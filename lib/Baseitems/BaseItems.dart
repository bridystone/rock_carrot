import 'package:flutter/material.dart';

/// the basic country item -> direct relation to land in database
enum ChildCountStatus {
  empty,
  update_in_progress,
}

class BaseItem {
  String name;
  double nr;
  int childCountInt;
  int? commentCountInt;
  String? commentCount;
  BaseItem({
    this.name = 'Root-BaseItem',
    this.nr = 0,
    // ignore: invalid_required_named_param
    @required this.childCountInt = 0,
    this.commentCountInt,
  });

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
    return item_a.name.compareTo(item_b.name);
  }

  /// sorting method Count DESC
  int sortByChildsDesc(BaseItem item_a, BaseItem item_b) {
    // explicitely use private integer!
    /// if nr is not empty, use this instead for sorting
    if (item_a.nr == 0 && item_b.nr == 0) {
      return item_b.childCountInt.compareTo(item_a.childCountInt);
    } else {
      return ((item_a.nr - item_b.nr) * 10).round();
    }
  }
}
