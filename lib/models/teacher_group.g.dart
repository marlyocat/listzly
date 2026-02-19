// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherGroup _$TeacherGroupFromJson(Map<String, dynamic> json) => TeacherGroup(
  id: json['id'] as String,
  teacherId: json['teacher_id'] as String,
  inviteCode: json['invite_code'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TeacherGroupToJson(TeacherGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacher_id': instance.teacherId,
      'invite_code': instance.inviteCode,
      'created_at': instance.createdAt.toIso8601String(),
    };
