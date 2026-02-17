import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/models/user_settings.dart';

class SettingsService {
  final SupabaseClient _client;
  SettingsService(this._client);

  Future<UserSettings> getSettings(String userId) async {
    final result = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (result != null) return UserSettings.fromJson(result);

    // Auto-create default settings for new users (e.g. Google sign-in)
    final created = await _client
        .from('user_settings')
        .insert({'user_id': userId})
        .select()
        .single();

    return UserSettings.fromJson(created);
  }

  Future<UserSettings> updateSettings(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    final result = await _client
        .from('user_settings')
        .update(updates)
        .eq('user_id', userId)
        .select()
        .single();

    return UserSettings.fromJson(result);
  }
}
