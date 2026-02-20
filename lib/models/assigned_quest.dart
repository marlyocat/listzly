import 'package:json_annotation/json_annotation.dart';

part 'assigned_quest.g.dart';

@JsonSerializable()
class AssignedQuest {
  final String id;
  @JsonKey(name: 'group_id')
  final String groupId;
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @JsonKey(name: 'student_id')
  final String studentId;
  @JsonKey(name: 'quest_key')
  final String questKey;
  final String title;
  final String description;
  final int target;
  @JsonKey(name: 'reward_xp')
  final int rewardXp;
  @JsonKey(name: 'icon_name')
  final String iconName;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const AssignedQuest({
    required this.id,
    required this.groupId,
    required this.teacherId,
    required this.studentId,
    required this.questKey,
    required this.title,
    this.description = '',
    required this.target,
    this.rewardXp = 0,
    this.iconName = 'assignment_rounded',
    this.isActive = true,
    this.isRecurring = false,
    required this.createdAt,
  });

  factory AssignedQuest.fromJson(Map<String, dynamic> json) =>
      _$AssignedQuestFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedQuestToJson(this);
}
