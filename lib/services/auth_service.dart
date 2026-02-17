import 'package:google_sign_in/google_sign_in.dart';
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
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
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

  Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: googleWebClientId,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google sign-in was cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw const AuthException('Failed to get Google ID token.');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _client.auth.signOut();
  }
}
