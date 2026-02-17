import 'package:json_annotation/json_annotation.dart';

part 'user_stats.g.dart';

@JsonSerializable()
class UserStats {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'total_xp')
  final int totalXp;
  @JsonKey(name: 'current_streak')
  final int currentStreak;
  @JsonKey(name: 'longest_streak')
  final int longestStreak;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const UserStats({
    required this.userId,
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.updatedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}
