import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/assigned_quest.dart';
import 'package:listzly/models/quest.dart';
import 'package:listzly/models/practice_session.dart';

/// Maximum number of active quests a teacher can assign per student.
const maxQuestsPerStudent = 3;

class AssignedQuestService {
  final SupabaseClient _client;
  AssignedQuestService(this._client);

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
  }) async {
    await _client
        .from('assigned_quests')
        .update({
          'title': title,
          'description': description,
          'target': target,
          'reward_xp': rewardXp,
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

  /// Get or initialize quest_progress rows for the student's assigned quests.
  Future<List<QuestProgress>> getAssignedQuestProgress(
      String studentId) async {
    final quests = await getAssignedQuestsForStudent(studentId);
    if (quests.isEmpty) return [];

    final progressList = <QuestProgress>[];

    for (final quest in quests) {
      final dateStr =
          quest.createdAt.toIso8601String().split('T')[0];

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
        // Initialize progress for this assigned quest.
        final result = await _client
            .from('quest_progress')
            .insert({
              'user_id': studentId,
              'quest_key': quest.questKey,
              'quest_type': 'assigned',
              'progress': 0,
              'target': quest.target,
              'completed': false,
              'period_start': dateStr,
            })
            .select()
            .single();
        progressList.add(QuestProgress.fromJson(result));
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
      final dateStr =
          quest.createdAt.toIso8601String().split('T')[0];
      await _incrementProgress(userId, quest.questKey, dateStr, 1);
    }
  }

  Future<void> _incrementProgress(
    String userId,
    String questKey,
    String periodStartStr,
    int amount,
  ) async {
    final existing = await _client
        .from('quest_progress')
        .select()
        .eq('user_id', userId)
        .eq('quest_key', questKey)
        .eq('period_start', periodStartStr)
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
        .eq('period_start', periodStartStr);
  }
}
