import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:listzly/models/profile.dart';
import 'package:listzly/services/profile_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'profile_provider.g.dart';

const profileCacheKey = 'cached_profile';

/// Pre-loaded SharedPreferences instance, set in main() before runApp.
late SharedPreferences prefsInstance;

@riverpod
ProfileService profileService(Ref ref) =>
    ProfileService(ref.watch(supabaseClientProvider));

@riverpod
Future<Profile> currentProfile(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');

  final cached = prefsInstance.getString(profileCacheKey);
  Profile? cachedProfile;
  if (cached != null) {
    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      cachedProfile = Profile.fromJson(json);
      if (cachedProfile.id != user.id) cachedProfile = null;
    } catch (_) {}
  }

  if (cachedProfile != null) {
    // Return cached profile instantly; refresh in background
    final service = ref.watch(profileServiceProvider);
    service.getProfile(user.id).then((fresh) {
      final freshJson = jsonEncode(fresh.toJson());
      if (freshJson != cached) {
        prefsInstance.setString(profileCacheKey, freshJson);
        ref.invalidateSelf();
      }
    }).catchError((_) {});
    return cachedProfile;
  }

  // No cache — must wait for network
  final fresh = await ref.watch(profileServiceProvider).getProfile(user.id);
  prefsInstance.setString(profileCacheKey, jsonEncode(fresh.toJson()));
  return fresh;
}
