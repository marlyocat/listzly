import 'package:json_annotation/json_annotation.dart';

part 'practice_session.g.dart';

@JsonSerializable()
class PracticeSession {
  final String? id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'instrument_name')
  final String instrumentName;
  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;
  @JsonKey(name: 'target_seconds')
  final int targetSeconds;
  @JsonKey(name: 'started_at')
  final DateTime startedAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'xp_earned')
  final int xpEarned;

  const PracticeSession({
    this.id,
    required this.userId,
    required this.instrumentName,
    required this.durationSeconds,
    required this.targetSeconds,
    required this.startedAt,
    this.completedAt,
    this.xpEarned = 0,
  });

  factory PracticeSession.fromJson(Map<String, dynamic> json) =>
      _$PracticeSessionFromJson(json);
  Map<String, dynamic> toJson() => _$PracticeSessionToJson(this);
}
