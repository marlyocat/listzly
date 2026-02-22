import 'package:json_annotation/json_annotation.dart';

part 'practice_recording.g.dart';

@JsonSerializable()
class PracticeRecording {
  final String? id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'session_id')
  final String? sessionId;
  @JsonKey(name: 'instrument_name')
  final String instrumentName;
  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;
  @JsonKey(name: 'file_path')
  final String filePath;
  @JsonKey(name: 'file_size_bytes')
  final int? fileSizeBytes;
  @JsonKey(name: 'shared_with_teacher')
  final bool sharedWithTeacher;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const PracticeRecording({
    this.id,
    required this.userId,
    this.sessionId,
    required this.instrumentName,
    required this.durationSeconds,
    required this.filePath,
    this.fileSizeBytes,
    this.sharedWithTeacher = false,
    required this.createdAt,
  });

  factory PracticeRecording.fromJson(Map<String, dynamic> json) =>
      _$PracticeRecordingFromJson(json);
  Map<String, dynamic> toJson() => _$PracticeRecordingToJson(this);
}
