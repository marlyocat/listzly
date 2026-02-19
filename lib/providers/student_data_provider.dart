import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/practice_session.dart';
import 'package:listzly/models/user_stats.dart';
import 'package:listzly/providers/session_provider.dart';
import 'package:listzly/providers/stats_provider.dart';

part 'student_data_provider.g.dart';

@riverpod
Future<UserStats> studentStats(
  StudentStatsRef ref, {
  required String studentId,
}) async {
  return ref.watch(statsServiceProvider).getStats(studentId);
}

@riverpod
Future<List<PracticeSession>> studentSessions(
  StudentSessionsRef ref, {
  required String studentId,
  required DateTime start,
  required DateTime end,
}) async {
  return ref.watch(sessionServiceProvider).getSessionsForRange(
        studentId,
        start,
        end,
      );
}

@riverpod
Future<Map<DateTime, int>> studentWeeklyBarData(
  StudentWeeklyBarDataRef ref, {
  required String studentId,
  required DateTime weekStart,
}) async {
  return ref.watch(sessionServiceProvider).getPracticeMinutesByDay(
        studentId,
        weekStart,
      );
}

@riverpod
Future<({Duration totalTime, int sessionCount})> studentSummaryStats(
  StudentSummaryStatsRef ref, {
  required String studentId,
  required DateTime start,
  required DateTime end,
}) async {
  return ref.watch(sessionServiceProvider).getSummaryStats(
        studentId,
        start,
        end,
      );
}

@riverpod
Future<List<Map<String, dynamic>>> studentInstrumentStats(
  StudentInstrumentStatsRef ref, {
  required String studentId,
}) async {
  return ref.watch(sessionServiceProvider).getInstrumentStats(studentId);
}
