import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/profile.dart';
import 'package:listzly/models/user_role.dart';

class ProfileService {
  final SupabaseClient _client;
  ProfileService(this._client);

  Future<Profile> getProfile(String userId) async {
    final result = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (result != null) {
      // Backfill display_name if null (e.g. Google sign-in trigger didn't set it)
      if (result['display_name'] == null) {
        final user = _client.auth.currentUser;
        final name = user?.userMetadata?['full_name'] as String? ??
            user?.userMetadata?['name'] as String? ??
            user?.email?.split('@').first ??
            'User';
        return updateProfile(userId, displayName: name);
      }
      return Profile.fromJson(result);
    }

    // Auto-create profile for new users (e.g. Google sign-in)
    final user = _client.auth.currentUser;
    final displayName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        user?.email?.split('@').first ??
        'User';

    final created = await _client
        .from('profiles')
        .insert({
          'id': userId,
          'display_name': displayName,
        })
        .select()
        .single();

    return Profile.fromJson(created);
  }

  Future<Profile> updateProfile(
    String userId, {
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    bool? roleSelected,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (role != null) updates['role'] = role.toJson();
    if (roleSelected != null) updates['role_selected'] = roleSelected;

    final result = await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return Profile.fromJson(result);
  }

  Future<void> updateSubscriptionTier(String userId, String tier) async {
    await _client
        .from('profiles')
        .update({'subscription_tier': tier})
        .eq('id', userId);
  }

  /// Get the teacher's profile for a student (via group membership).
  Future<Profile?> getTeacherProfile(String studentId) async {
    final membership = await _client
        .from('group_members')
        .select('group_id')
        .eq('student_id', studentId)
        .maybeSingle();

    if (membership == null) return null;

    final group = await _client
        .from('teacher_groups')
        .select('teacher_id')
        .eq('id', membership['group_id'])
        .maybeSingle();

    if (group == null) return null;

    final teacherProfile = await _client
        .from('profiles')
        .select()
        .eq('id', group['teacher_id'])
        .maybeSingle();

    if (teacherProfile == null) return null;
    return Profile.fromJson(teacherProfile);
  }
}
