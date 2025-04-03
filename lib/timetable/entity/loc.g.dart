// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimetableDayLoc _$TimetableDayLocFromJson(Map<String, dynamic> json) => TimetableDayLoc(
      mode: $enumDecode(_$TimetableDayLocModeEnumMap, json['mode']),
      posInternal: json['pos'] == null ? null : TimetablePos.fromJson(json['pos'] as Map<String, dynamic>),
      dateInternal: json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$TimetableDayLocToJson(TimetableDayLoc instance) => <String, dynamic>{
      'mode': _$TimetableDayLocModeEnumMap[instance.mode]!,
      if (instance.posInternal case final value?) 'pos': value,
      if (instance.dateInternal?.toIso8601String() case final value?) 'date': value,
    };

const _$TimetableDayLocModeEnumMap = {
  TimetableDayLocMode.pos: 'pos',
  TimetableDayLocMode.date: 'date',
};
