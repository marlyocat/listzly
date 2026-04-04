import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/practice_recording.dart';

class RecordingService {
  static const _recordingsBucket = 'listzly-recordings';
  static const _recordingsDir = 'recordings';

  final SupabaseClient _client;
  RecordingService(this._client);

  /// Get the local recordings directory (creates it if needed).
  Future<Directory> _getRecordingsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_recordingsDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Call the r2-storage Edge Function with retry (used only for teacher sharing).
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

  /// Save a recording locally and insert metadata into Supabase.
  Future<PracticeRecording> saveRecording({
    required String userId,
    required String? sessionId,
    required String instrumentName,
    required int durationSeconds,
    required String localFilePath,
  }) async {
    final tempFile = File(localFilePath);
    final fileSize = await tempFile.length();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'recording_$timestamp.m4a';

    // Move from temp to permanent local storage
    final recordingsDir = await _getRecordingsDir();
    final permanentPath = '${recordingsDir.path}/$fileName';
    await tempFile.copy(permanentPath);
    await tempFile.delete();

    // Insert metadata row (file_path stores just the filename)
    final data = {
      'user_id': userId,
      'session_id': sessionId,
      'instrument_name': instrumentName,
      'duration_seconds': durationSeconds,
      'file_path': fileName,
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

  /// Get the full local file path for a recording.
  Future<String> getLocalPath(String fileName) async {
    final recordingsDir = await _getRecordingsDir();
    return '${recordingsDir.path}/$fileName';
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
  /// When sharing, uploads the local file to R2 so the teacher can stream it.
  /// When unsharing, removes the R2 copy.
  Future<void> setShared(String recordingId, String fileName, String userId, bool shared) async {
    final cloudPath = '$userId/$fileName';

    if (shared) {
      // Upload local file to R2 for teacher access
      final localPath = await getLocalPath(fileName);
      final file = File(localPath);
      final fileBytes = await file.readAsBytes();

      final result = await _callR2Function(
        action: 'upload',
        bucket: _recordingsBucket,
        filePath: cloudPath,
      );
      final signedUrl = result['signedUrl'] as String;

      final response = await http.put(
        Uri.parse(signedUrl),
        headers: {'Content-Type': 'audio/mp4'},
        body: fileBytes,
      );
      if (response.statusCode != 200) {
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } else {
      // Remove R2 copy
      try {
        await _callR2Function(
          action: 'delete',
          bucket: _recordingsBucket,
          filePath: cloudPath,
        );
      } catch (e) {
        debugPrint('Failed to delete R2 file on unshare: $e');
      }
    }

    await _client
        .from('practice_recordings')
        .update({'shared_with_teacher': shared})
        .eq('id', recordingId);
  }

  /// Delete an R2 file by path (used for teacher-side cleanup).
  Future<void> deleteR2File(String fileName, String userId) async {
    final cloudPath = '$userId/$fileName';
    await _callR2Function(
      action: 'delete',
      bucket: _recordingsBucket,
      filePath: cloudPath,
    );
  }

  /// Get a signed URL for playback (teacher streaming shared recordings).
  Future<String> getSignedUrl(String fileName, String userId) async {
    final cloudPath = '$userId/$fileName';
    final result = await _callR2Function(
      action: 'download',
      bucket: _recordingsBucket,
      filePath: cloudPath,
    );
    return result['signedUrl'] as String;
  }

  /// Delete recording (local file + R2 if shared + database row).
  Future<void> deleteRecording(String recordingId, String fileName, String userId, bool isShared) async {
    // Remove local file
    try {
      final localPath = await getLocalPath(fileName);
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete local recording file: $e');
    }

    // Remove R2 file if it was shared
    if (isShared) {
      try {
        await _callR2Function(
          action: 'delete',
          bucket: _recordingsBucket,
          filePath: '$userId/$fileName',
        );
      } catch (e) {
        debugPrint('Failed to delete R2 file: $e');
      }
    }

    // Remove database row
    await _client
        .from('practice_recordings')
        .delete()
        .eq('id', recordingId);
  }
}
