// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UpdateStatus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateStatus _$UpdateStatusFromJson(Map<String, dynamic> json) {
  return UpdateStatus(
    _$enumDecode(_$UpdateTypeEnumMap, json['type']),
    json['id'] as String,
    UpdateStatus._dateTimeFromEpochUs(json['timestamp'] as int?),
  );
}

Map<String, dynamic> _$UpdateStatusToJson(UpdateStatus instance) =>
    <String, dynamic>{
      'type': _$UpdateTypeEnumMap[instance.type],
      'id': instance.id,
      'timestamp': UpdateStatus._dateTimeToEpochUs(instance.timestamp),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$UpdateTypeEnumMap = {
  UpdateType.country: 'country',
  UpdateType.area: 'area',
  UpdateType.subarea: 'subarea',
  UpdateType.rock: 'rock',
};
