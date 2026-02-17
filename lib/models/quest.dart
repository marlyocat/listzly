import 'package:json_annotation/json_annotation.dart';

part 'quest.g.dart';

@JsonSerializable()
class QuestProgress {
  final String? id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'quest_key')
  final String questKey;
  @JsonKey(name: 'quest_type')
  final String questType;
  final int progress;
  final int target;
  final bool completed;
  @JsonKey(name: 'period_start')
  final DateTime periodStart;

  const QuestProgress({
    this.id,
    required this.userId,
    required this.questKey,
    this.questType = 'daily',
    this.progress = 0,
    required this.target,
    this.completed = false,
    required this.periodStart,
  });

  factory QuestProgress.fromJson(Map<String, dynamic> json) =>
      _$QuestProgressFromJson(json);
  Map<String, dynamic> toJson() => _$QuestProgressToJson(this);
}
