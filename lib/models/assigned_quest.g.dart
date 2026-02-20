// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_quest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedQuest _$AssignedQuestFromJson(Map<String, dynamic> json) =>
    AssignedQuest(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      teacherId: json['teacher_id'] as String,
      studentId: json['student_id'] as String,
      questKey: json['quest_key'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      target: (json['target'] as num).toInt(),
      rewardXp: (json['reward_xp'] as num?)?.toInt() ?? 0,
      iconName: json['icon_name'] as String? ?? 'assignment_rounded',
      isActive: json['is_active'] as bool? ?? true,
      isRecurring: json['is_recurring'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AssignedQuestToJson(AssignedQuest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'teacher_id': instance.teacherId,
      'student_id': instance.studentId,
      'quest_key': instance.questKey,
      'title': instance.title,
      'description': instance.description,
      'target': instance.target,
      'reward_xp': instance.rewardXp,
      'icon_name': instance.iconName,
      'is_active': instance.isActive,
      'is_recurring': instance.isRecurring,
      'created_at': instance.createdAt.toIso8601String(),
    };
