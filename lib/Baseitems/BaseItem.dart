class BaseItem {
  final int id;
  final String name;
  final int childCount;
  BaseItem(this.id, this.name, this.childCount);

  factory BaseItem.fromSql(Map<String, Object?> sqlResult) {
    return BaseItem(
      int.parse(sqlResult['gebiet_ID'].toString()),
      sqlResult['gebiet'].toString(),
      sqlResult['gebiet'].toString().length, // should be subareacount
    );
  }
}
