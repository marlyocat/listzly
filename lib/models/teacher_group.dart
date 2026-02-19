import 'package:json_annotation/json_annotation.dart';

part 'teacher_group.g.dart';

@JsonSerializable()
class TeacherGroup {
  final String id;
  @JsonKey(name: 'teacher_id')
  final String teacherId;
  @JsonKey(name: 'invite_code')
  final String inviteCode;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TeacherGroup({
    required this.id,
    required this.teacherId,
    required this.inviteCode,
    required this.createdAt,
  });

  factory TeacherGroup.fromJson(Map<String, dynamic> json) =>
      _$TeacherGroupFromJson(json);
  Map<String, dynamic> toJson() => _$TeacherGroupToJson(this);
}
