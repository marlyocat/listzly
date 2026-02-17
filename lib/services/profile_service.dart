import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/profile.dart';

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
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    final result = await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return Profile.fromJson(result);
  }
}
