import 'package:json_annotation/json_annotation.dart';

part 'group_notification.g.dart';

@JsonSerializable()
class GroupNotification {
  final String id;
  @JsonKey(name: 'group_id')
  final String groupId;
  final String message;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const GroupNotification({
    required this.id,
    required this.groupId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory GroupNotification.fromJson(Map<String, dynamic> json) =>
      _$GroupNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$GroupNotificationToJson(this);
}
