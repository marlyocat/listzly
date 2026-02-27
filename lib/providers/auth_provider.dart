import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/services/auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) =>
    Supabase.instance.client;

@riverpod
AuthService authService(Ref ref) =>
    AuthService(ref.watch(supabaseClientProvider));

@riverpod
Stream<AuthState> authStateChanges(Ref ref) =>
    ref.watch(authServiceProvider).authStateChanges;

@riverpod
User? currentUser(Ref ref) {
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentUser;
}
