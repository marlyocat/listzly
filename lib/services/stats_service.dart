import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/user_stats.dart';

class StatsService {
  final SupabaseClient _client;
  StatsService(this._client);

  Future<UserStats> getStats(String userId) async {
    final result = await _client
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (result != null) return UserStats.fromJson(result);

    // Auto-create default stats for new users (e.g. Google sign-in)
    final created = await _client
        .from('user_stats')
        .insert({'user_id': userId})
        .select()
        .single();

    return UserStats.fromJson(created);
  }

  /// Recalculate streak + total XP from practice_sessions and update user_stats.
  Future<UserStats> recalculateStats(String userId) async {
    // Get all sessions ordered by date
    final sessions = await _client
        .from('practice_sessions')
        .select('completed_at, xp_earned')
        .eq('user_id', userId)
        .order('completed_at', ascending: false);

    final sessionList = sessions as List;

    // Total XP
    final totalXp = sessionList.fold<int>(
        0, (sum, e) => sum + ((e as Map<String, dynamic>)['xp_earned'] as int));

    // Calculate streak: count consecutive days with sessions ending today
    final practiceDays = sessionList
        .map((e) {
          final dt = DateTime.parse(
              (e as Map<String, dynamic>)['completed_at'] as String);
          return DateTime(dt.year, dt.month, dt.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    int currentStreak = 0;
    final today = DateTime.now();
    var checkDate = DateTime(today.year, today.month, today.day);

    for (final day in practiceDays) {
      if (day == checkDate) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (day.isBefore(checkDate)) {
        break;
      }
    }

    // If no session today, check if streak continues from yesterday
    if (currentStreak == 0 && practiceDays.isNotEmpty) {
      final yesterday = checkDate.subtract(const Duration(days: 1));
      checkDate = yesterday;
      for (final day in practiceDays) {
        if (day == checkDate) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (day.isBefore(checkDate)) {
          break;
        }
      }
    }

    // Get existing longest streak
    final existing = await _client
        .from('user_stats')
        .select('longest_streak')
        .eq('user_id', userId)
        .single();

    final longestStreak = currentStreak >
            (existing['longest_streak'] as int)
        ? currentStreak
        : existing['longest_streak'] as int;

    final result = await _client
        .from('user_stats')
        .update({
          'total_xp': totalXp,
          'current_streak': currentStreak,
          'longest_streak': longestStreak,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .select()
        .single();

    return UserStats.fromJson(result);
  }
}
