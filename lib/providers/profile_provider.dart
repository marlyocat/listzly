import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/profile.dart';
import 'package:listzly/services/profile_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileService profileService(ProfileServiceRef ref) =>
    ProfileService(ref.watch(supabaseClientProvider));

@riverpod
Future<Profile> currentProfile(CurrentProfileRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(profileServiceProvider).getProfile(user.id);
}
