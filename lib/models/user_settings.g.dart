// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
  userId: json['user_id'] as String,
  theme: json['theme'] as String? ?? 'system',
  language: json['language'] as String? ?? 'English',
  firstDayOfWeek: json['first_day_of_week'] as String? ?? 'Monday',
  dailyGoalMinutes: (json['daily_goal_minutes'] as num?)?.toInt() ?? 15,
  reminderTime: json['reminder_time'] as String?,
  soundEffects: json['sound_effects'] as bool? ?? true,
  showProgressBar: json['show_progress_bar'] as bool? ?? true,
);

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'theme': instance.theme,
      'language': instance.language,
      'first_day_of_week': instance.firstDayOfWeek,
      'daily_goal_minutes': instance.dailyGoalMinutes,
      'reminder_time': instance.reminderTime,
      'sound_effects': instance.soundEffects,
      'show_progress_bar': instance.showProgressBar,
    };
