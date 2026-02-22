import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/practice_recording.dart';

class RecordingService {
  final SupabaseClient _client;
  RecordingService(this._client);

  /// Upload a recording file to Supabase Storage, then insert metadata row.
  Future<PracticeRecording> uploadRecording({
    required String userId,
    required String? sessionId,
    required String instrumentName,
    required int durationSeconds,
    required String localFilePath,
  }) async {
    final file = File(localFilePath);
    final fileSize = await file.length();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = '$userId/$timestamp.m4a';

    // Upload to storage
    await _client.storage.from('recordings').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(contentType: 'audio/mp4'),
        );

    // Insert metadata row
    final data = {
      'user_id': userId,
      'session_id': sessionId,
      'instrument_name': instrumentName,
      'duration_seconds': durationSeconds,
      'file_path': storagePath,
      'file_size_bytes': fileSize,
      'created_at': DateTime.now().toIso8601String(),
    };

    final result = await _client
        .from('practice_recordings')
        .insert(data)
        .select()
        .single();

    return PracticeRecording.fromJson(result);
  }

  /// Fetch recordings for the current user.
  Future<List<PracticeRecording>> getUserRecordings(String userId) async {
    final result = await _client
        .from('practice_recordings')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (result as List)
        .map((e) => PracticeRecording.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch shared recordings for a specific student (teacher view).
  Future<List<PracticeRecording>> getStudentRecordings(
      String studentId) async {
    final result = await _client
        .from('practice_recordings')
        .select()
        .eq('user_id', studentId)
        .eq('shared_with_teacher', true)
        .order('created_at', ascending: false);

    return (result as List)
        .map((e) => PracticeRecording.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Toggle sharing a recording with the teacher.
  Future<void> setShared(String recordingId, bool shared) async {
    await _client
        .from('practice_recordings')
        .update({'shared_with_teacher': shared})
        .eq('id', recordingId);
  }

  /// Get a signed URL for playback (1 hour expiry).
  Future<String> getSignedUrl(String filePath) async {
    return _client.storage
        .from('recordings')
        .createSignedUrl(filePath, 3600);
  }

  /// Delete recording (storage file + database row).
  Future<void> deleteRecording(String recordingId, String filePath) async {
    // Remove storage file
    try {
      await _client.storage.from('recordings').remove([filePath]);
    } catch (_) {
      // Storage deletion failure shouldn't block DB cleanup
    }

    // Remove database row
    await _client
        .from('practice_recordings')
        .delete()
        .eq('id', recordingId);
  }
}
