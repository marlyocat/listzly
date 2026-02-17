import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/services/auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) =>
    Supabase.instance.client;

@riverpod
AuthService authService(AuthServiceRef ref) =>
    AuthService(ref.watch(supabaseClientProvider));

@riverpod
Stream<AuthState> authStateChanges(AuthStateChangesRef ref) =>
    ref.watch(authServiceProvider).authStateChanges;

@riverpod
User? currentUser(CurrentUserRef ref) {
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentUser;
}
