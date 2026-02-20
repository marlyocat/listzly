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

    // Practice session XP
    final sessionXp = sessionList.fold<int>(
        0, (sum, e) => sum + ((e as Map<String, dynamic>)['xp_earned'] as int));

    // Assigned quest reward XP
    int questBonusXp = 0;
    try {
      final completedAssigned = await _client
          .from('quest_progress')
          .select('quest_key')
          .eq('user_id', userId)
          .eq('quest_type', 'assigned')
          .eq('completed', true);

      if ((completedAssigned as List).isNotEmpty) {
        final assignedQuests = await _client
            .from('assigned_quests')
            .select('quest_key, reward_xp')
            .eq('student_id', userId);

        final rewardMap = <String, int>{};
        for (final aq in assignedQuests as List) {
          final m = aq as Map<String, dynamic>;
          rewardMap[m['quest_key'] as String] = m['reward_xp'] as int;
        }

        // Each completed quest_progress row = one reward
        // (recurring quests have multiple completed rows, one per week)
        for (final cp in completedAssigned as List) {
          final key = (cp as Map<String, dynamic>)['quest_key'] as String;
          questBonusXp += rewardMap[key] ?? 0;
        }
      }
    } catch (_) {
      // Non-critical: if quest XP lookup fails, just use session XP
    }

    // Total XP
    final totalXp = sessionXp + questBonusXp;

    // Calculate streak with 3-day grace period:
    // The streak counts actual practice days but only resets after
    // 3 consecutive days with no practice.
    final practiceDaySet = sessionList
        .map((e) {
          final dt = DateTime.parse(
              (e as Map<String, dynamic>)['completed_at'] as String);
          return DateTime(dt.year, dt.month, dt.day);
        })
        .toSet();

    int currentStreak = 0;
    final today = DateTime.now();
    var date = DateTime(today.year, today.month, today.day);

    if (practiceDaySet.isNotEmpty) {
      int consecutiveGap = 0;
      while (true) {
        if (practiceDaySet.contains(date)) {
          currentStreak++;
          consecutiveGap = 0;
        } else {
          consecutiveGap++;
          if (consecutiveGap >= 3) break;
        }
        date = date.subtract(const Duration(days: 1));
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
