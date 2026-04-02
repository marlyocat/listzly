import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/practice_session.dart';

/// Persists unsaved practice sessions to SharedPreferences so they survive
/// app restarts and can be retried when connectivity returns.
class OfflineSessionQueue {
  static const _key = 'offline_session_queue';

  static Future<void> enqueue(PracticeSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(session.toJson()));
    await prefs.setStringList(_key, list);
    debugPrint('OfflineSessionQueue: enqueued session (${list.length} pending)');
  }

  static Future<List<PracticeSession>> pending() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list
        .map((e) => PracticeSession.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> get hasPending async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.isNotEmpty;
  }

  /// Retry saving all queued sessions to Supabase.
  /// Successfully saved sessions are removed from the queue.
  static Future<void> flush() async {
    final sessions = await pending();
    if (sessions.isEmpty) return;

    debugPrint('OfflineSessionQueue: flushing ${sessions.length} pending session(s)');
    final client = Supabase.instance.client;
    final failed = <PracticeSession>[];

    for (final session in sessions) {
      try {
        final xp = (session.durationSeconds / 60).ceil();
        await client.from('practice_sessions').insert({
          'user_id': session.userId,
          'instrument_name': session.instrumentName,
          'duration_seconds': session.durationSeconds,
          'target_seconds': session.targetSeconds,
          'started_at': session.startedAt.toIso8601String(),
          'completed_at': session.completedAt?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'xp_earned': xp,
        });
      } catch (e) {
        debugPrint('OfflineSessionQueue: failed to save session: $e');
        failed.add(session);
      }
    }

    // Replace queue with only the sessions that still failed
    final prefs = await SharedPreferences.getInstance();
    if (failed.isEmpty) {
      await prefs.remove(_key);
      debugPrint('OfflineSessionQueue: all sessions saved successfully');
    } else {
      await prefs.setStringList(
        _key,
        failed.map((s) => jsonEncode(s.toJson())).toList(),
      );
      debugPrint('OfflineSessionQueue: ${failed.length} session(s) still pending');
    }
  }
}
