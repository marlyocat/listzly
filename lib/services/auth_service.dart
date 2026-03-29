import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client;
  AuthService(this._client);

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.caplock.listzly://login-callback',
    );
  }

  Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId: googleWebClientId,
    );
    final googleUser = await googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      throw const AuthException('Failed to get Google ID token.');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signOut() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('Purchases.logOut failed (user may be anonymous): $e');
    }
    await GoogleSignIn.instance.signOut();
    await _client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    final response = await _client.functions.invoke('delete-account');
    if (response.status != 200) {
      throw Exception('Account deletion failed');
    }

    // Clear all local data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Sign out of third-party services (best-effort, user is already deleted)
    try { await Purchases.logOut(); } catch (_) {}
    try { await GoogleSignIn.instance.signOut(); } catch (_) {}
    try { await _client.auth.signOut(); } catch (_) {}
  }
}
