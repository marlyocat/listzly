import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/teacher_group.dart';
import 'package:listzly/models/group_member.dart';
import 'package:listzly/models/student_summary.dart';

class GroupService {
  final SupabaseClient _client;
  GroupService(this._client);

  // ─── Invite Code Generation ──────────────────────────────────

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  // ─── Teacher Group Management ────────────────────────────────

  Future<TeacherGroup> createGroup(String teacherId) async {
    // Check if a group already exists (e.g. from a previous role switch)
    final existing = await getTeacherGroup(teacherId);
    if (existing != null) return existing;

    final code = _generateInviteCode();
    final result = await _client
        .from('teacher_groups')
        .insert({
          'teacher_id': teacherId,
          'invite_code': code,
        })
        .select()
        .single();
    return TeacherGroup.fromJson(result);
  }

  Future<TeacherGroup?> getTeacherGroup(String teacherId) async {
    final result = await _client
        .from('teacher_groups')
        .select()
        .eq('teacher_id', teacherId)
        .maybeSingle();
    return result != null ? TeacherGroup.fromJson(result) : null;
  }

  Future<TeacherGroup> regenerateInviteCode(String groupId) async {
    final code = _generateInviteCode();
    final result = await _client
        .from('teacher_groups')
        .update({'invite_code': code})
        .eq('id', groupId)
        .select()
        .single();
    return TeacherGroup.fromJson(result);
  }

  Future<void> deleteGroup(String groupId) async {
    await _client.from('teacher_groups').delete().eq('id', groupId);
  }

  // ─── Student Joining / Leaving ───────────────────────────────

  Future<TeacherGroup?> findGroupByInviteCode(String code) async {
    final result = await _client
        .from('teacher_groups')
        .select()
        .eq('invite_code', code.toUpperCase().trim())
        .maybeSingle();
    return result != null ? TeacherGroup.fromJson(result) : null;
  }

  Future<GroupMember> joinGroup(String studentId, String groupId) async {
    final countResult = await _client
        .from('group_members')
        .select('id')
        .eq('group_id', groupId);
    if ((countResult as List).length >= 20) {
      throw Exception('This group is full (20 students max).');
    }

    final existing = await _client
        .from('group_members')
        .select()
        .eq('student_id', studentId)
        .maybeSingle();
    if (existing != null) {
      throw Exception('You are already in a group. Leave first to join another.');
    }

    final result = await _client
        .from('group_members')
        .insert({
          'group_id': groupId,
          'student_id': studentId,
        })
        .select()
        .single();
    return GroupMember.fromJson(result);
  }

  Future<void> leaveGroup(String studentId) async {
    await _client.from('group_members').delete().eq('student_id', studentId);
  }

  Future<GroupMember?> getStudentMembership(String studentId) async {
    final result = await _client
        .from('group_members')
        .select()
        .eq('student_id', studentId)
        .maybeSingle();
    return result != null ? GroupMember.fromJson(result) : null;
  }

  Future<bool> isStudentInGroup(String studentId) async {
    final result = await _client
        .from('group_members')
        .select('id')
        .eq('student_id', studentId)
        .maybeSingle();
    return result != null;
  }

  // ─── Teacher Dashboard ───────────────────────────────────────

  Future<List<StudentSummary>> getStudentsWithStats(String teacherId) async {
    final group = await getTeacherGroup(teacherId);
    if (group == null) return [];

    final membersResult = await _client
        .from('group_members')
        .select('student_id, joined_at')
        .eq('group_id', group.id)
        .order('joined_at', ascending: true);

    final members = membersResult as List;
    if (members.isEmpty) return [];

    final studentIds = members
        .map((m) => (m as Map<String, dynamic>)['student_id'] as String)
        .toList();

    final profilesResult = await _client
        .from('profiles')
        .select('id, display_name, avatar_url')
        .inFilter('id', studentIds);

    final statsResult = await _client
        .from('user_stats')
        .select('user_id, total_xp, current_streak')
        .inFilter('user_id', studentIds);

    final profileMap = <String, Map<String, dynamic>>{};
    for (final p in profilesResult as List) {
      final pm = p as Map<String, dynamic>;
      profileMap[pm['id'] as String] = pm;
    }

    final statsMap = <String, Map<String, dynamic>>{};
    for (final s in statsResult as List) {
      final sm = s as Map<String, dynamic>;
      statsMap[sm['user_id'] as String] = sm;
    }

    return members.map((m) {
      final mm = m as Map<String, dynamic>;
      final sid = mm['student_id'] as String;
      final profile = profileMap[sid];
      final stats = statsMap[sid];

      return StudentSummary(
        studentId: sid,
        displayName: (profile?['display_name'] as String?) ?? 'Unknown',
        avatarUrl: profile?['avatar_url'] as String?,
        totalXp: (stats?['total_xp'] as int?) ?? 0,
        currentStreak: (stats?['current_streak'] as int?) ?? 0,
        joinedAt: DateTime.parse(mm['joined_at'] as String),
      );
    }).toList();
  }

  Future<void> removeStudent(String groupId, String studentId) async {
    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('student_id', studentId);
  }

  Future<int> getMemberCount(String groupId) async {
    final result = await _client
        .from('group_members')
        .select('id')
        .eq('group_id', groupId);
    return (result as List).length;
  }

  /// Get the teacher's profile for a group (used by students to see their teacher's name).
  Future<String?> getTeacherName(String groupId) async {
    final group = await _client
        .from('teacher_groups')
        .select('teacher_id')
        .eq('id', groupId)
        .maybeSingle();
    if (group == null) return null;

    final profile = await _client
        .from('profiles')
        .select('display_name')
        .eq('id', group['teacher_id'] as String)
        .maybeSingle();
    return profile?['display_name'] as String?;
  }
}
