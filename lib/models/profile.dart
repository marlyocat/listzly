import 'package:json_annotation/json_annotation.dart';
import 'package:listzly/models/user_role.dart';

part 'profile.g.dart';

String _roleToJson(UserRole role) => role.toJson();

@JsonSerializable()
class Profile {
  final String id;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(fromJson: UserRole.fromJson, toJson: _roleToJson)
  final UserRole role;
  @JsonKey(name: 'role_selected')
  final bool roleSelected;

  const Profile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
    this.role = UserRole.selfLearner,
    this.roleSelected = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    bool? roleSelected,
  }) =>
      Profile(
        id: id,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
        role: role ?? this.role,
        roleSelected: roleSelected ?? this.roleSelected,
      );

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
  bool get isSelfLearner => role == UserRole.selfLearner;
}
