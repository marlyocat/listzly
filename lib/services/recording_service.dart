import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/practice_recording.dart';

class RecordingService {
  static const _recordingsBucket = 'listzly-recordings';

  final SupabaseClient _client;
  RecordingService(this._client);

  /// Call the r2-storage Edge Function with retry.
  Future<Map<String, dynamic>> _callR2Function({
    required String action,
    required String bucket,
    required String filePath,
  }) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _client.functions.invoke(
          'r2-storage',
          body: {
            'action': action,
            'bucket': bucket,
            'filePath': filePath,
          },
        );

        if (response.status != 200) {
          throw Exception('R2 function failed: ${response.data}');
        }

        return response.data as Map<String, dynamic>;
      } catch (e) {
        if (attempt == maxAttempts) rethrow;
        debugPrint('R2 function attempt $attempt failed: $e');
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw Exception('R2 function failed after $maxAttempts attempts');
  }

  /// Upload a recording file to R2 via presigned URL, then insert metadata row.
  /// Retries the upload up to 3 times on failure.
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

    // Get presigned upload URL from Edge Function
    final result = await _callR2Function(
      action: 'upload',
      bucket: _recordingsBucket,
      filePath: storagePath,
    );
    final signedUrl = result['signedUrl'] as String;

    // Upload to R2 with retry
    final fileBytes = await file.readAsBytes();
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http.put(
          Uri.parse(signedUrl),
          headers: {'Content-Type': 'audio/mp4'},
          body: fileBytes,
        );
        if (response.statusCode != 200) {
          throw Exception('Upload failed with status ${response.statusCode}');
        }
        break;
      } catch (e) {
        if (attempt == maxAttempts) rethrow;
        debugPrint('Recording upload attempt $attempt failed: $e');
        await Future.delayed(Duration(seconds: attempt));
      }
    }

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

    final row = await _client
        .from('practice_recordings')
        .insert(data)
        .select()
        .single();

    return PracticeRecording.fromJson(row);
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
    final result = await _callR2Function(
      action: 'download',
      bucket: _recordingsBucket,
      filePath: filePath,
    );
    return result['signedUrl'] as String;
  }

  /// Delete recording (R2 file + database row).
  Future<void> deleteRecording(String recordingId, String filePath) async {
    // Remove R2 file
    try {
      await _callR2Function(
        action: 'delete',
        bucket: _recordingsBucket,
        filePath: filePath,
      );
    } catch (e) {
      // Storage deletion failure shouldn't block DB cleanup
      debugPrint('Failed to delete R2 file: $e');
    }

    // Remove database row
    await _client
        .from('practice_recordings')
        .delete()
        .eq('id', recordingId);
  }
}
