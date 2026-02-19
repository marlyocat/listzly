import 'package:json_annotation/json_annotation.dart';

part 'group_member.g.dart';

@JsonSerializable()
class GroupMember {
  final String id;
  @JsonKey(name: 'group_id')
  final String groupId;
  @JsonKey(name: 'student_id')
  final String studentId;
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.studentId,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);
  Map<String, dynamic> toJson() => _$GroupMemberToJson(this);
}
