// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
  id: json['id'] as String,
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  role: json['role'] == null
      ? UserRole.selfLearner
      : UserRole.fromJson(json['role'] as String),
  roleSelected: json['role_selected'] as bool? ?? false,
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'role': _roleToJson(instance.role),
  'role_selected': instance.roleSelected,
};
