import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/user_stats.dart';
import 'package:listzly/services/stats_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'stats_provider.g.dart';

@riverpod
StatsService statsService(StatsServiceRef ref) =>
    StatsService(ref.watch(supabaseClientProvider));

@riverpod
Future<UserStats> userStats(UserStatsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(statsServiceProvider).getStats(user.id);
}
