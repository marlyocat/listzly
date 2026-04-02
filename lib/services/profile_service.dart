import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/profile.dart';
import 'package:listzly/models/subscription_tier.dart';
import 'package:listzly/models/user_role.dart';
import 'package:listzly/utils/avatar_options.dart';

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
      final needsName = result['display_name'] == null;
      final needsAvatar = result['avatar_url'] == null;
      if (needsName || needsAvatar) {
        final user = _client.auth.currentUser;
        final name = needsName
            ? (user?.userMetadata?['full_name'] as String? ??
                user?.userMetadata?['name'] as String? ??
                user?.email?.split('@').first ??
                'User')
            : null;
        final avatar = needsAvatar
            ? '$avatarDir/${avatarOptions[Random().nextInt(avatarOptions.length)].$1}'
            : null;
        return updateProfile(userId, displayName: name, avatarUrl: avatar);
      }
      return Profile.fromJson(result);
    }

    // Auto-create profile for new users (e.g. Google sign-in)
    final user = _client.auth.currentUser;
    final displayName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        user?.email?.split('@').first ??
        'User';

    final randomAvatar =
        '$avatarDir/${avatarOptions[Random().nextInt(avatarOptions.length)].$1}';

    final created = await _client
        .from('profiles')
        .insert({
          'id': userId,
          'display_name': displayName,
          'avatar_url': randomAvatar,
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

  Future<void> updateSubscriptionTier(
      String userId, SubscriptionTier tier) async {
    await _client
        .from('profiles')
        .update({'subscription_tier': tier.toDbString()})
        .eq('id', userId);
  }

}
