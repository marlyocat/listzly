import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/song.dart';

class MusicService {
  static const _bucket = 'listzly-background-music';

  final SupabaseClient _client;
  MusicService(this._client);

  /// Call the r2-storage Edge Function with retry.
  Future<Map<String, dynamic>> _callR2Function({
    required String action,
    required String filePath,
  }) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _client.functions.invoke(
          'r2-storage',
          body: {
            'action': action,
            'bucket': _bucket,
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

  /// Fetch all available songs from the database.
  Future<List<Song>> getSongs() async {
    final result = await _client
        .from('songs')
        .select()
        .order('title', ascending: true);

    return (result as List)
        .map((e) => Song.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a signed URL for a cover image (1 hour expiry).
  Future<String?> getCoverUrl(String? coverPath) async {
    if (coverPath == null || coverPath.isEmpty) return null;
    final result = await _callR2Function(
      action: 'download',
      filePath: coverPath,
    );
    return result['signedUrl'] as String;
  }

  /// Get a signed URL for streaming a song (1 hour expiry).
  Future<String> getSignedUrl(String filePath) async {
    final result = await _callR2Function(
      action: 'download',
      filePath: filePath,
    );
    return result['signedUrl'] as String;
  }
}
