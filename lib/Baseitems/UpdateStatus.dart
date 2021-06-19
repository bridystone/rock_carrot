import 'package:json_annotation/json_annotation.dart';

/// to be generated with
/// `flutter pub run build_runner build`
part 'UpdateStatus.g.dart';

enum UpdateType {
  country,
  area,
  subarea,
  rock,
}

@JsonSerializable()
class UpdateStatus {
  UpdateType type;
  String id;
  @JsonKey(
    fromJson: _dateTimeFromEpochUs,
    toJson: _dateTimeToEpochUs,
  )
  DateTime timestamp;

  UpdateStatus(this.type, this.id, this.timestamp);

  factory UpdateStatus.fromJson(Map<String, dynamic> json) =>
      _$UpdateStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateStatusToJson(this);

  /// handling datetime
  static DateTime _dateTimeFromEpochUs(int? us) =>
      DateTime.fromMicrosecondsSinceEpoch(us ?? 0);

  static int? _dateTimeToEpochUs(DateTime? dateTime) =>
      dateTime?.microsecondsSinceEpoch;
}
