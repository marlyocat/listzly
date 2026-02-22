import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/quest.dart';
import 'package:listzly/services/quest_service.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/settings_provider.dart';

part 'quest_provider.g.dart';

@riverpod
QuestService questService(QuestServiceRef ref) =>
    QuestService(ref.watch(supabaseClientProvider));

@riverpod
Future<List<QuestProgress>> dailyQuests(DailyQuestsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');

  final settings = await ref.watch(userSettingsNotifierProvider.future);
  return ref.watch(questServiceProvider).getDailyQuests(
        user.id,
        dailyGoalMinutes: settings.dailyGoalMinutes,
      );
}

@riverpod
Future<List<bool>> weekCompletionStatus(WeekCompletionStatusRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(questServiceProvider).getWeekCompletionStatus(user.id);
}
