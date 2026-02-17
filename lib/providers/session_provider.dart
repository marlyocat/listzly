import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/practice_session.dart';
import 'package:listzly/services/session_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'session_provider.g.dart';

@riverpod
SessionService sessionService(SessionServiceRef ref) =>
    SessionService(ref.watch(supabaseClientProvider));

@riverpod
Future<List<PracticeSession>> sessionList(
  SessionListRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(sessionServiceProvider).getSessionsForRange(
        user.id,
        start,
        end,
      );
}

@riverpod
Future<Map<DateTime, int>> weeklyBarData(
  WeeklyBarDataRef ref, {
  required DateTime weekStart,
}) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(sessionServiceProvider).getSessionCountsByDay(
        user.id,
        weekStart,
      );
}

@riverpod
Future<({Duration totalTime, int sessionCount})> summaryStats(
  SummaryStatsRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(sessionServiceProvider).getSummaryStats(
        user.id,
        start,
        end,
      );
}
