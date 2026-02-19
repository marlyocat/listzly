import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/teacher_group.dart';
import 'package:listzly/models/group_member.dart';
import 'package:listzly/models/student_summary.dart';
import 'package:listzly/services/group_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'group_provider.g.dart';

@riverpod
GroupService groupService(GroupServiceRef ref) =>
    GroupService(ref.watch(supabaseClientProvider));

@riverpod
Future<TeacherGroup?> teacherGroup(TeacherGroupRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(groupServiceProvider).getTeacherGroup(user.id);
}

@riverpod
Future<GroupMember?> studentMembership(StudentMembershipRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(groupServiceProvider).getStudentMembership(user.id);
}

@riverpod
Future<bool> isInGroup(IsInGroupRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return ref.watch(groupServiceProvider).isStudentInGroup(user.id);
}

@riverpod
Future<List<StudentSummary>> teacherStudents(TeacherStudentsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(groupServiceProvider).getStudentsWithStats(user.id);
}
