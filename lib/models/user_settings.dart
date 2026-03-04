import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

@JsonSerializable()
class UserSettings {
  @JsonKey(name: 'user_id')
  final String userId;
  final String theme;
  final String language;
  @JsonKey(name: 'first_day_of_week')
  final String firstDayOfWeek;
  @JsonKey(name: 'daily_goal_minutes')
  final int dailyGoalMinutes;
  @JsonKey(name: 'reminder_time')
  final String? reminderTime;
  @JsonKey(name: 'sound_effects')
  final bool soundEffects;
  @JsonKey(name: 'show_progress_bar')
  final bool showProgressBar;

  const UserSettings({
    required this.userId,
    this.theme = 'system',
    this.language = 'English',
    this.firstDayOfWeek = 'Monday',
    this.dailyGoalMinutes = 15,
    this.reminderTime,
    this.soundEffects = true,
    this.showProgressBar = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
}
