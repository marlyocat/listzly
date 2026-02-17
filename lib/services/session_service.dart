import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/practice_session.dart';

class SessionService {
  final SupabaseClient _client;
  SessionService(this._client);

  /// Save a completed practice session.
  /// XP formula: 1 XP per minute + 5 bonus if target met.
  Future<PracticeSession> saveSession(PracticeSession session) async {
    final minutes = (session.durationSeconds / 60).ceil();
    final metTarget = session.durationSeconds >= session.targetSeconds;
    final xp = minutes + (metTarget ? 5 : 0);

    final data = {
      'user_id': session.userId,
      'instrument_name': session.instrumentName,
      'duration_seconds': session.durationSeconds,
      'target_seconds': session.targetSeconds,
      'started_at': session.startedAt.toIso8601String(),
      'completed_at': DateTime.now().toIso8601String(),
      'xp_earned': xp,
    };

    final result = await _client
        .from('practice_sessions')
        .insert(data)
        .select()
        .single();

    return PracticeSession.fromJson(result);
  }

  /// Fetch sessions for a date range (Activity page).
  Future<List<PracticeSession>> getSessionsForRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final result = await _client
        .from('practice_sessions')
        .select()
        .eq('user_id', userId)
        .gte('completed_at', start.toIso8601String())
        .lte('completed_at', end.toIso8601String())
        .order('completed_at', ascending: false);

    return (result as List)
        .map((e) => PracticeSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get session counts by day for bar chart (returns day -> session count).
  Future<Map<DateTime, int>> getSessionCountsByDay(
    String userId,
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final sessions = await getSessionsForRange(userId, weekStart, weekEnd);

    final counts = <DateTime, int>{};
    for (var i = 0; i < 7; i++) {
      final day = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + i,
      );
      counts[day] = 0;
    }

    for (final session in sessions) {
      final completed = session.completedAt ?? session.startedAt;
      final day = DateTime(completed.year, completed.month, completed.day);
      counts[day] = (counts[day] ?? 0) + 1;
    }

    return counts;
  }

  /// Get total practice time and session count for a date range.
  Future<({Duration totalTime, int sessionCount})> getSummaryStats(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final sessions = await getSessionsForRange(userId, start, end);
    final totalSeconds =
        sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return (
      totalTime: Duration(seconds: totalSeconds),
      sessionCount: sessions.length,
    );
  }

  /// Per-instrument stats for Profile page.
  Future<List<Map<String, dynamic>>> getInstrumentStats(String userId) async {
    final result = await _client
        .from('practice_sessions')
        .select()
        .eq('user_id', userId);

    final sessions = (result as List)
        .map((e) => PracticeSession.fromJson(e as Map<String, dynamic>));

    final statsMap = <String, Map<String, dynamic>>{};
    for (final session in sessions) {
      final name = session.instrumentName;
      if (!statsMap.containsKey(name)) {
        statsMap[name] = {'name': name, 'minutes': 0, 'sessions': 0};
      }
      statsMap[name]!['minutes'] =
          (statsMap[name]!['minutes'] as int) + (session.durationSeconds ~/ 60);
      statsMap[name]!['sessions'] = (statsMap[name]!['sessions'] as int) + 1;
    }

    return statsMap.values.toList()
      ..sort((a, b) =>
          (b['minutes'] as int).compareTo(a['minutes'] as int));
  }
}
