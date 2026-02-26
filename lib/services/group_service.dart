import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/teacher_group.dart';
import 'package:listzly/models/group_member.dart';
import 'package:listzly/models/group_notification.dart';
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

  Future<GroupMember> joinGroup(String studentId, String groupId,
      {required String teacherId}) async {
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

    // Notify the teacher
    try {
      final profile = await _client
          .from('profiles')
          .select('display_name')
          .eq('id', studentId)
          .maybeSingle();
      final name = (profile?['display_name'] as String?) ?? 'A student';
      await _client.from('group_notifications').insert({
        'group_id': groupId,
        'message': '$name has joined the group.',
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Failed to insert join notification: $e');
    }

    return GroupMember.fromJson(result);
  }

  Future<void> leaveGroup(String studentId) async {
    // Look up the group and student name before deleting
    final membership = await getStudentMembership(studentId);
    String? studentName;
    if (membership != null) {
      try {
        final profile = await _client
            .from('profiles')
            .select('display_name')
            .eq('id', studentId)
            .maybeSingle();
        studentName = profile?['display_name'] as String?;
      } catch (_) {}
    }

    await _client.from('group_members').delete().eq('student_id', studentId);

    // Notify the teacher
    if (membership != null) {
      final name = studentName ?? 'A student';
      try {
        await _client.from('group_notifications').insert({
          'group_id': membership.groupId,
          'message': '$name has left the group.',
          'is_read': false,
        });
      } catch (e) {
        debugPrint('Failed to insert leave notification: $e');
      }
    }
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
    // Look up student name before deleting
    String? studentName;
    try {
      final profile = await _client
          .from('profiles')
          .select('display_name')
          .eq('id', studentId)
          .maybeSingle();
      studentName = profile?['display_name'] as String?;
    } catch (_) {}

    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('student_id', studentId);

    // Revert student role to self-learner
    try {
      await _client
          .from('profiles')
          .update({'role': 'self_learner'})
          .eq('id', studentId);
    } catch (e) {
      debugPrint('Failed to revert student role: $e');
    }

    // Notify
    final name = studentName ?? 'A student';
    try {
      await _client.from('group_notifications').insert({
        'group_id': groupId,
        'message': '$name was removed from the group.',
        'is_read': false,
      });
    } catch (e) {
      debugPrint('Failed to insert remove notification: $e');
    }
  }

  Future<int> getMemberCount(String groupId) async {
    final result = await _client
        .from('group_members')
        .select('id')
        .eq('group_id', groupId);
    return (result as List).length;
  }

  // ─── Group Notifications ────────────────────────────────────

  Future<List<GroupNotification>> getUnreadNotifications(String groupId) async {
    final result = await _client
        .from('group_notifications')
        .select()
        .eq('group_id', groupId)
        .eq('is_read', false)
        .order('created_at', ascending: false);
    return (result as List)
        .map((e) => GroupNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<GroupNotification>> getAllNotifications(String groupId) async {
    final result = await _client
        .from('group_notifications')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: false);
    return (result as List)
        .map((e) => GroupNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationsRead(String groupId) async {
    await _client
        .from('group_notifications')
        .update({'is_read': true})
        .eq('group_id', groupId)
        .eq('is_read', false);
  }

  Future<void> deleteAllNotifications(String groupId) async {
    await _client
        .from('group_notifications')
        .delete()
        .eq('group_id', groupId);
  }

  /// Get the teacher's profile for a group (used by students to see their teacher's name).
  Future<String?> getTeacherName(String groupId) async {
    try {
      final result = await _client
          .from('teacher_groups')
          .select('profiles(display_name)')
          .eq('id', groupId)
          .maybeSingle();
      if (result == null) return null;
      final profiles = result['profiles'] as Map<String, dynamic>?;
      return profiles?['display_name'] as String?;
    } catch (e) {
      return null;
    }
  }
}
