import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  final String id;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({String? displayName, String? avatarUrl}) => Profile(
        id: id,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
      );
}
