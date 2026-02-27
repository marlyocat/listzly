import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/user_settings.dart';
import 'package:listzly/services/settings_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'settings_provider.g.dart';

@riverpod
SettingsService settingsService(Ref ref) =>
    SettingsService(ref.watch(supabaseClientProvider));

@riverpod
class UserSettingsNotifier extends _$UserSettingsNotifier {
  @override
  Future<UserSettings> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) throw Exception('Not authenticated');
    return ref.watch(settingsServiceProvider).getSettings(user.id);
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    state = AsyncData(
      await ref.read(settingsServiceProvider).updateSettings(
            user.id,
            {key: value},
          ),
    );
  }
}
