// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instrument.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Instrument _$InstrumentFromJson(Map<String, dynamic> json) => Instrument(
  id: json['id'] as String?,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$InstrumentToJson(Instrument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
    };
