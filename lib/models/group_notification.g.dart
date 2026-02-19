// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupNotification _$GroupNotificationFromJson(Map<String, dynamic> json) =>
    GroupNotification(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$GroupNotificationToJson(GroupNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'message': instance.message,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
    };
