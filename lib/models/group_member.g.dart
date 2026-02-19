// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) => GroupMember(
  id: json['id'] as String,
  groupId: json['group_id'] as String,
  studentId: json['student_id'] as String,
  joinedAt: DateTime.parse(json['joined_at'] as String),
);

Map<String, dynamic> _$GroupMemberToJson(GroupMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'student_id': instance.studentId,
      'joined_at': instance.joinedAt.toIso8601String(),
    };
