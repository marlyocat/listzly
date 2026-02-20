import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/assigned_quest.dart';
import 'package:listzly/models/quest.dart';
import 'package:listzly/models/practice_session.dart';

/// Maximum number of active quests a teacher can assign per student.
const maxQuestsPerStudent = 3;

class AssignedQuestService {
  final SupabaseClient _client;
  AssignedQuestService(this._client);

  // ─── Helpers ────────────────────────────────────────────

  /// Monday of the current week.
  DateTime _weekStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  /// Returns the period_start date string for a quest.
  String _periodStart(AssignedQuest quest) {
    if (quest.isRecurring) {
      return _weekStart().toIso8601String().split('T')[0];
    }
    return quest.createdAt.toIso8601String().split('T')[0];
  }

  // ─── Teacher Methods ──────────────────────────────────────

  /// Create a new assigned quest for a specific student.
  ///
  /// Throws if the student already has [maxQuestsPerStudent] active quests.
  Future<AssignedQuest> createQuest({
    required String groupId,
    required String teacherId,
    required String studentId,
    required String questKey,
    required String title,
    required String description,
    required int target,
    required int rewardXp,
    String iconName = 'assignment_rounded',
    bool isRecurring = false,
  }) async {
    // Enforce per-student limit.
    final existing = await _client
        .from('assigned_quests')
        .select('id')
        .eq('student_id', studentId)
        .eq('is_active', true);
    if ((existing as List).length >= maxQuestsPerStudent) {
      throw Exception(
          'This student already has $maxQuestsPerStudent active quests.');
    }

    final result = await _client
        .from('assigned_quests')
        .insert({
          'group_id': groupId,
          'teacher_id': teacherId,
          'student_id': studentId,
          'quest_key': questKey,
          'title': title,
          'description': description,
          'target': target,
          'reward_xp': rewardXp,
          'icon_name': iconName,
          'is_active': true,
          'is_recurring': isRecurring,
        })
        .select()
        .single();
    return AssignedQuest.fromJson(result);
  }

  /// Get all active assigned quests for a group.
  Future<List<AssignedQuest>> getActiveQuestsForGroup(String groupId) async {
    final result = await _client
        .from('assigned_quests')
        .select()
        .eq('group_id', groupId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (result as List)
        .map((e) => AssignedQuest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Update an existing assigned quest.
  Future<void> updateQuest({
    required String questId,
    required String title,
    required String description,
    required int target,
    required int rewardXp,
    required bool isRecurring,
  }) async {
    await _client
        .from('assigned_quests')
        .update({
          'title': title,
          'description': description,
          'target': target,
          'reward_xp': rewardXp,
          'is_recurring': isRecurring,
        })
        .eq('id', questId);
  }

  /// Deactivate a quest (soft-delete).
  Future<void> deactivateQuest(String questId) async {
    await _client
        .from('assigned_quests')
        .update({'is_active': false})
        .eq('id', questId);
  }

  /// Delete a quest entirely.
  Future<void> deleteQuest(String questId) async {
    await _client.from('assigned_quests').delete().eq('id', questId);
  }

  // ─── Student Methods ──────────────────────────────────────

  /// Get active assigned quests for a specific student.
  Future<List<AssignedQuest>> getAssignedQuestsForStudent(
      String studentId) async {
    final result = await _client
        .from('assigned_quests')
        .select()
        .eq('student_id', studentId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (result as List)
        .map((e) => AssignedQuest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get quest progress for the student's assigned quests.
  ///
  /// Returns existing progress from the database, or a local zero-progress
  /// object when no row exists yet (progress rows are created during practice).
  Future<List<QuestProgress>> getAssignedQuestProgress(
      String studentId) async {
    final quests = await getAssignedQuestsForStudent(studentId);
    if (quests.isEmpty) return [];

    final progressList = <QuestProgress>[];

    for (final quest in quests) {
      final dateStr = _periodStart(quest);
      final periodStartDt = quest.isRecurring ? _weekStart() : quest.createdAt;

      // Check for existing progress.
      final existing = await _client
          .from('quest_progress')
          .select()
          .eq('user_id', studentId)
          .eq('quest_key', quest.questKey)
          .eq('quest_type', 'assigned')
          .eq('period_start', dateStr)
          .maybeSingle();

      if (existing != null) {
        progressList.add(QuestProgress.fromJson(existing));
      } else {
        // Return a synthetic progress object for display only.
        progressList.add(QuestProgress(
          userId: studentId,
          questKey: quest.questKey,
          questType: 'assigned',
          progress: 0,
          target: quest.target,
          completed: false,
          periodStart: periodStartDt,
        ));
      }
    }

    return progressList;
  }

  // ─── Progress Update ──────────────────────────────────────

  /// Update assigned quest progress after a practice session.
  ///
  /// Custom quests increment by 1 per completed session.
  Future<void> updateAssignedQuestProgressAfterSession(
    String userId,
    PracticeSession session,
  ) async {
    final quests = await getAssignedQuestsForStudent(userId);
    if (quests.isEmpty) return;

    for (final quest in quests) {
      final dateStr = _periodStart(quest);
      await _incrementProgress(userId, quest, dateStr, 1);
    }
  }

  Future<void> _incrementProgress(
    String userId,
    AssignedQuest quest,
    String periodStartStr,
    int amount,
  ) async {
    final existing = await _client
        .from('quest_progress')
        .select()
        .eq('user_id', userId)
        .eq('quest_key', quest.questKey)
        .eq('period_start', periodStartStr)
        .maybeSingle();

    final bool wasAlreadyCompleted;
    final int newProgress;

    if (existing == null) {
      // Create progress row on first practice session.
      newProgress = amount;
      wasAlreadyCompleted = false;
      await _client.from('quest_progress').insert({
        'user_id': userId,
        'quest_key': quest.questKey,
        'quest_type': 'assigned',
        'progress': newProgress,
        'target': quest.target,
        'completed': newProgress >= quest.target,
        'period_start': periodStartStr,
      });
    } else {
      final current = existing['progress'] as int;
      final existingTarget = existing['target'] as int;
      wasAlreadyCompleted = existing['completed'] as bool;
      newProgress = current + amount;

      await _client
          .from('quest_progress')
          .update({
            'progress': newProgress,
            'completed': newProgress >= existingTarget,
          })
          .eq('user_id', userId)
          .eq('quest_key', quest.questKey)
          .eq('period_start', periodStartStr);
    }

    // ── On-completion side effects (fire only on first completion) ──
    final justCompleted = newProgress >= quest.target && !wasAlreadyCompleted;
    if (!justCompleted) return;

    // 1. Auto-deactivate one-time quests.
    if (!quest.isRecurring) {
      await _client
          .from('assigned_quests')
          .update({'is_active': false})
          .eq('id', quest.id);
    }

    // 2. Notify teacher.
    try {
      final profile = await _client
          .from('profiles')
          .select('display_name')
          .eq('id', userId)
          .maybeSingle();
      final name = (profile?['display_name'] as String?) ?? 'A student';
      await _client.from('group_notifications').insert({
        'group_id': quest.groupId,
        'message': '$name completed quest \'${quest.title}\'',
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Failed to send quest completion notification: $e');
    }

    // 3. XP award is handled by recalculateStats (called after this method).
  }
}
