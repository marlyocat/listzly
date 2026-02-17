// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeSession _$PracticeSessionFromJson(Map<String, dynamic> json) =>
    PracticeSession(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      instrumentName: json['instrument_name'] as String,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      targetSeconds: (json['target_seconds'] as num).toInt(),
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PracticeSessionToJson(PracticeSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'instrument_name': instance.instrumentName,
      'duration_seconds': instance.durationSeconds,
      'target_seconds': instance.targetSeconds,
      'started_at': instance.startedAt.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'xp_earned': instance.xpEarned,
    };
