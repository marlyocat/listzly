import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/theme/colors.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      if (_isLogin) {
        await authService.signIn(email: email, password: password);
      } else {
        final displayName = _displayNameController.text.trim();
        await authService.signUp(
          email: email,
          password: password,
          displayName: displayName.isNotEmpty ? displayName : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/homepage',
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.signInWithGoogle();

      if (mounted) {
        final user = response.user;
        final name = user?.userMetadata?['full_name'] as String? ??
            user?.userMetadata?['name'] as String? ??
            user?.email ??
            'Google';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in as $name'),
            backgroundColor: accentCoral,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/homepage',
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      _showError(e.message);
    } catch (e, stackTrace) {
      debugPrint('Google sign-in error: $e');
      debugPrint('Stack trace: $stackTrace');
      _showError('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: accentCoralDark,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.nunito(
        color: darkTextMuted,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: darkTextMuted, size: 20),
      filled: true,
      fillColor: Colors.white.withAlpha(12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withAlpha(30)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withAlpha(30)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentCoral, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Brand name
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, accentCoral],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Music Man',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to continue your practice'
                    : 'Start your musical journey',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: darkTextSecondary,
                ),
              ),

              const SizedBox(height: 36),

              // Display name field (sign up only)
              if (!_isLogin) ...[
                TextField(
                  controller: _displayNameController,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration:
                      _inputDecoration('Display Name', Icons.person_outline),
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                decoration:
                    _inputDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                decoration:
                    _inputDecoration('Password', Icons.lock_outline),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: const LinearGradient(
                      colors: [accentCoral, accentCoralDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentCoral.withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isLogin ? 'Sign In' : 'Sign Up',
                            style: GoogleFonts.nunito(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withAlpha(30))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: GoogleFonts.nunito(
                        color: darkTextMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white.withAlpha(30))),
                ],
              ),

              const SizedBox(height: 24),

              // Google sign-in button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Text(
                    'G',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  label: Text(
                    'Continue with Google',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withAlpha(30)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Toggle login/signup
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _isLogin = !_isLogin),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkTextMuted,
                      ),
                      children: [
                        TextSpan(
                          text: _isLogin
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                        ),
                        TextSpan(
                          text: _isLogin ? 'Sign Up' : 'Sign In',
                          style: const TextStyle(
                            color: accentCoral,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
