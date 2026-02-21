import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/practice_recording.dart';
import 'package:listzly/services/recording_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'recording_provider.g.dart';

@riverpod
RecordingService recordingService(RecordingServiceRef ref) =>
    RecordingService(ref.watch(supabaseClientProvider));

@riverpod
Future<List<PracticeRecording>> userRecordings(UserRecordingsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(recordingServiceProvider).getUserRecordings(user.id);
}

@riverpod
Future<List<PracticeRecording>> studentRecordings(
  StudentRecordingsRef ref, {
  required String studentId,
}) async {
  return ref.watch(recordingServiceProvider).getStudentRecordings(studentId);
}
