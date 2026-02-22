import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/quest.dart';
import 'package:listzly/models/practice_session.dart';

/// Quest definitions — same for all users. DB only stores progress.
class QuestDefinition {
  final String key;
  final String type;
  final String title;
  final String description;
  final int target;
  final int rewardXp;

  const QuestDefinition({
    required this.key,
    required this.type,
    required this.title,
    required this.description,
    required this.target,
    required this.rewardXp,
  });
}

const dailyQuestDefinitions = [
  QuestDefinition(
    key: 'daily_xp_30',
    type: 'daily',
    title: 'Play an instrument',
    description: 'Practice any instrument',
    target: 1,
    rewardXp: 10,
  ),
  QuestDefinition(
    key: 'daily_practice_20m',
    type: 'daily',
    title: 'Practice for 20 minutes',
    description: 'Reach your daily practice goal',
    target: 20,
    rewardXp: 15,
  ),
  QuestDefinition(
    key: 'daily_sessions_2',
    type: 'daily',
    title: 'Complete 1 session',
    description: 'Finish a full practice session',
    target: 1,
    rewardXp: 20,
  ),
];

class QuestService {
  final SupabaseClient _client;
  QuestService(this._client);

  /// Deduplicate quest rows by quest_key, keeping the first occurrence.
  List<QuestProgress> _deduplicateByQuestKey(List<dynamic> rows) {
    final seen = <String>{};
    final results = <QuestProgress>[];
    for (final row in rows) {
      final qp = QuestProgress.fromJson(row as Map<String, dynamic>);
      if (seen.add(qp.questKey)) {
        results.add(qp);
      }
    }
    return results;
  }

  DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _weekStart() {
    final now = DateTime.now();
    final weekday = now.weekday; // Monday = 1
    return DateTime(now.year, now.month, now.day - (weekday - 1));
  }

  /// Get or initialize today's daily quests.
  ///
  /// [dailyGoalMinutes] overrides the practice quest target so it matches
  /// the user's daily-goal setting from their profile.
  Future<List<QuestProgress>> getDailyQuests(
    String userId, {
    required int dailyGoalMinutes,
  }) async {
    final today = _todayStart();
    final dateStr = today.toIso8601String().split('T')[0];

    final existing = await _client
        .from('quest_progress')
        .select()
        .eq('user_id', userId)
        .eq('quest_type', 'daily')
        .eq('period_start', dateStr)
        .order('quest_key');

    if (existing.isNotEmpty) {
      final quests = _deduplicateByQuestKey(existing);

      // Sync the practice quest target if the user changed their daily goal.
      final practiceQuest = quests.cast<QuestProgress?>().firstWhere(
            (q) => q!.questKey == 'daily_practice_20m',
            orElse: () => null,
          );
      if (practiceQuest != null && practiceQuest.target != dailyGoalMinutes) {
        await _client
            .from('quest_progress')
            .update({
              'target': dailyGoalMinutes,
              'completed': practiceQuest.progress >= dailyGoalMinutes,
            })
            .eq('user_id', userId)
            .eq('quest_key', 'daily_practice_20m')
            .eq('period_start', dateStr);

        // Return refreshed data.
        final refreshed = await _client
            .from('quest_progress')
            .select()
            .eq('user_id', userId)
            .eq('quest_type', 'daily')
            .eq('period_start', dateStr)
            .order('quest_key');
        return _deduplicateByQuestKey(refreshed);
      }

      return quests;
    }

    // Initialize daily quests for today
    final inserts = dailyQuestDefinitions
        .map((d) => {
              'user_id': userId,
              'quest_key': d.key,
              'quest_type': 'daily',
              'progress': 0,
              'target': d.key == 'daily_practice_20m'
                  ? dailyGoalMinutes
                  : d.target,
              'completed': false,
              'period_start': dateStr,
            })
        .toList();

    final result =
        await _client.from('quest_progress').insert(inserts).select();

    return _deduplicateByQuestKey(result);
  }

  /// Update quest progress after a session is saved.
  Future<void> updateQuestProgressAfterSession(
    String userId,
    PracticeSession session,
  ) async {
    final today = _todayStart();
    final minutesPracticed = (session.durationSeconds / 60).ceil();

    // --- Daily quests ---
    await _incrementQuest(userId, 'daily_xp_30', today, 1);
    await _incrementQuest(userId, 'daily_practice_20m', today, minutesPracticed);
    await _incrementQuest(userId, 'daily_sessions_2', today, 1);
  }

  Future<void> _incrementQuest(
    String userId,
    String questKey,
    DateTime periodStart,
    int amount,
  ) async {
    final dateStr = periodStart.toIso8601String().split('T')[0];

    final existing = await _client
        .from('quest_progress')
        .select()
        .eq('user_id', userId)
        .eq('quest_key', questKey)
        .eq('period_start', dateStr)
        .maybeSingle();

    if (existing == null) return;

    final current = existing['progress'] as int;
    final target = existing['target'] as int;
    final newProgress = current + amount;

    await _client
        .from('quest_progress')
        .update({
          'progress': newProgress,
          'completed': newProgress >= target,
        })
        .eq('user_id', userId)
        .eq('quest_key', questKey)
        .eq('period_start', dateStr);
  }

  /// Get week completion status (bool per day: practiced or not).
  Future<List<bool>> getWeekCompletionStatus(String userId) async {
    final weekStart = _weekStart();
    final weekEnd = weekStart.add(const Duration(days: 7));

    final sessions = await _client
        .from('practice_sessions')
        .select('completed_at')
        .eq('user_id', userId)
        .gte('completed_at', weekStart.toIso8601String())
        .lte('completed_at', weekEnd.toIso8601String());

    final practicedDays = (sessions as List).map((e) {
      final dt = DateTime.parse(
          (e as Map<String, dynamic>)['completed_at'] as String);
      return DateTime(dt.year, dt.month, dt.day);
    }).toSet();

    return List.generate(7, (i) {
      final day = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + i,
      );
      return practicedDays.contains(day);
    });
  }
}
