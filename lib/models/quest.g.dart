// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestProgress _$QuestProgressFromJson(Map<String, dynamic> json) =>
    QuestProgress(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      questKey: json['quest_key'] as String,
      questType: json['quest_type'] as String? ?? 'daily',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num).toInt(),
      completed: json['completed'] as bool? ?? false,
      periodStart: DateTime.parse(json['period_start'] as String),
    );

Map<String, dynamic> _$QuestProgressToJson(QuestProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'quest_key': instance.questKey,
      'quest_type': instance.questType,
      'progress': instance.progress,
      'target': instance.target,
      'completed': instance.completed,
      'period_start': instance.periodStart.toIso8601String(),
    };
