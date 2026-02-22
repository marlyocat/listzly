// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_recording.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeRecording _$PracticeRecordingFromJson(Map<String, dynamic> json) =>
    PracticeRecording(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      sessionId: json['session_id'] as String?,
      instrumentName: json['instrument_name'] as String,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      filePath: json['file_path'] as String,
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt(),
      sharedWithTeacher: json['shared_with_teacher'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PracticeRecordingToJson(PracticeRecording instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'session_id': instance.sessionId,
      'instrument_name': instance.instrumentName,
      'duration_seconds': instance.durationSeconds,
      'file_path': instance.filePath,
      'file_size_bytes': instance.fileSizeBytes,
      'shared_with_teacher': instance.sharedWithTeacher,
      'created_at': instance.createdAt.toIso8601String(),
    };
