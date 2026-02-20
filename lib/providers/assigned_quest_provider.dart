import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/assigned_quest.dart';
import 'package:listzly/models/quest.dart';
import 'package:listzly/services/assigned_quest_service.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/group_provider.dart';

part 'assigned_quest_provider.g.dart';

@riverpod
AssignedQuestService assignedQuestService(AssignedQuestServiceRef ref) =>
    AssignedQuestService(ref.watch(supabaseClientProvider));

/// For students: fetch quest progress for their assigned quests.
@riverpod
Future<List<QuestProgress>> assignedQuestProgress(
    AssignedQuestProgressRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(assignedQuestServiceProvider).getAssignedQuestProgress(user.id);
}

/// For students: fetch the AssignedQuest definitions (for title, icon, etc.).
@riverpod
Future<List<AssignedQuest>> assignedQuestDefinitions(
    AssignedQuestDefinitionsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref
      .watch(assignedQuestServiceProvider)
      .getAssignedQuestsForStudent(user.id);
}

/// For teachers: fetch active quests they've assigned to their group.
@riverpod
Future<List<AssignedQuest>> teacherAssignedQuests(
    TeacherAssignedQuestsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  final group = await ref.watch(teacherGroupProvider.future);
  if (group == null) return [];
  return ref
      .watch(assignedQuestServiceProvider)
      .getActiveQuestsForGroup(group.id);
}
