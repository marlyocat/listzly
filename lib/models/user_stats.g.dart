// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
  userId: json['user_id'] as String,
  totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
  currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
  'user_id': instance.userId,
  'total_xp': instance.totalXp,
  'current_streak': instance.currentStreak,
  'longest_streak': instance.longestStreak,
  'updated_at': instance.updatedAt.toIso8601String(),
};
