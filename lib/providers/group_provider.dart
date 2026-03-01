import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/teacher_group.dart';
import 'package:listzly/models/group_member.dart';
import 'package:listzly/models/group_notification.dart';
import 'package:listzly/models/student_summary.dart';
import 'package:listzly/services/group_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'group_provider.g.dart';

@riverpod
GroupService groupService(Ref ref) =>
    GroupService(ref.watch(supabaseClientProvider));

@riverpod
Future<TeacherGroup?> teacherGroup(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(groupServiceProvider).getTeacherGroup(user.id);
}

@riverpod
Stream<GroupMember?> studentMembership(Ref ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield null;
    return;
  }

  final client = ref.watch(supabaseClientProvider);

  // Emit initial value immediately to avoid disposal-during-loading errors.
  // The Supabase .stream() needs time to establish a WebSocket connection;
  // if the provider is disposed before that, Riverpod throws.
  final initial = await client
      .from('group_members')
      .select()
      .eq('student_id', user.id)
      .maybeSingle();
  yield initial != null ? GroupMember.fromJson(initial) : null;

  // Then switch to real-time stream for subsequent changes
  yield* client
      .from('group_members')
      .stream(primaryKey: ['id'])
      .eq('student_id', user.id)
      .map((rows) {
        if (rows.isEmpty) return null;
        return GroupMember.fromJson(rows.first);
      });
}

@riverpod
Future<bool> isInGroup(Ref ref) async {
  final membership = await ref.watch(studentMembershipProvider.future);
  return membership != null;
}

@riverpod
Future<List<StudentSummary>> teacherStudents(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(groupServiceProvider).getStudentsWithStats(user.id);
}

@riverpod
Stream<List<GroupNotification>> unreadGroupNotifications(
    Ref ref) async* {
  final group = await ref.watch(teacherGroupProvider.future);
  if (group == null) {
    yield [];
    return;
  }

  final client = ref.watch(supabaseClientProvider);
  yield* client
      .from('group_notifications')
      .stream(primaryKey: ['id'])
      .eq('group_id', group.id)
      .order('created_at', ascending: false)
      .map((rows) => rows
          .where((e) => e['is_read'] != true)
          .map((e) => GroupNotification.fromJson(e))
          .toList());
}
