import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:listzly/pages/auth_gate.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/responsive.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
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

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (!_isLogin && password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      if (_isLogin) {
        await authService.signIn(email: email, password: password);
      } else {
        final displayName = _displayNameController.text.trim();
        final response = await authService.signUp(
          email: email,
          password: password,
          displayName: displayName.isNotEmpty ? displayName : null,
        );

        // Detect repeated sign-up (existing unconfirmed account)
        final user = response.user;
        if (user != null &&
            (user.identities == null || user.identities!.isEmpty)) {
          if (mounted) {
            setState(() => _isLogin = true);
            _showError('An account with this email already exists. Please sign in instead.');
          }
          return;
        }
      }

      if (mounted) {
        if (_isLogin) {
          Navigator.of(context).pushAndRemoveUntil(
            _turnPageRoute(const AuthGate()),
            (route) => false,
          );
        } else {
          // Sign-up: prompt user to confirm email, then switch to login view
          setState(() => _isLogin = true);
          _emailController.clear();
          _passwordController.clear();
          _displayNameController.clear();
          _showConfirmEmailDialog();
        }
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
      await authService.signInWithGoogle();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          _turnPageRoute(const AuthGate()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      _showError(e.message);
    } catch (e, stackTrace) {
      debugPrint('Google sign-in error: $e');
      debugPrint('Stack trace: $stackTrace');
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') || msg.contains('abort') || msg.contains('dismissed')) {
        _showError('Google sign-in cancelled');
      } else {
        _showError('Google sign-in failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Route _turnPageRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (animation.status == AnimationStatus.reverse) {
          return FadeTransition(opacity: animation, child: child);
        }
        return TurnPageTransition(
          animation: animation,
          overleafColor: primaryDark,
          animationTransitionPoint: 0.5,
          direction: TurnDirection.rightToLeft,
          child: child,
        );
      },
    );
  }

  void _showConfirmEmailDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E0A4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Check Your Email',
          style: TextStyle(fontFamily: 'DM Serif Display',
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        content: Text(
          'We\'ve sent a confirmation link to your email address. Please verify your email, then sign in.',
          style: TextStyle(fontFamily: 'Nunito',
            color: darkTextSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(fontFamily: 'Nunito',
                color: accentCoral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E0A4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Password',
          style: TextStyle(fontFamily: 'DM Serif Display',
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email and we\'ll send you a link to reset your password.',
              style: TextStyle(fontFamily: 'Nunito',
                color: darkTextSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontFamily: 'Nunito',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: _inputDecoration('Email', Icons.email_outlined),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Nunito',
                color: darkTextMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              Navigator.of(context).pop();
              try {
                final authService = ref.read(authServiceProvider);
                await authService.resetPassword(email);
                if (mounted) {
                  _showResetEmailSentDialog();
                }
              } on AuthException catch (e) {
                if (mounted) _showError(e.message);
              } catch (_) {
                if (mounted) {
                  _showError('Something went wrong. Please try again.');
                }
              }
            },
            child: Text(
              'Send',
              style: TextStyle(fontFamily: 'Nunito',
                color: accentCoral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetEmailSentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E0A4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Check Your Email',
          style: TextStyle(fontFamily: 'DM Serif Display',
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        content: Text(
          'We\'ve sent a password reset link to your email. Please check your inbox (and spam folder).',
          style: TextStyle(fontFamily: 'Nunito',
            color: darkTextSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(fontFamily: 'Nunito',
                color: accentCoral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: true,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontFamily: 'Nunito',
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
        child: ContentConstraint(
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
                  'Listzly',
                  style: TextStyle(fontFamily: 'DM Serif Display',
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                _isLogin ? 'Welcome' : 'Create Account',
                style: TextStyle(fontFamily: 'DM Serif Display',
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to start practising'
                    : 'Start your musical journey',
                style: TextStyle(fontFamily: 'Nunito',
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
                  style: TextStyle(fontFamily: 'Nunito',
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
                style: TextStyle(fontFamily: 'Nunito',
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
                obscureText: _obscurePassword,
                style: TextStyle(fontFamily: 'Nunito',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: darkTextMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              if (_isLogin) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showForgotPasswordDialog,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accentCoral,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit button
              GestureDetector(
                onTap: _isLoading ? null : _submit,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [accentCoral, accentCoralDark],
                    ),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: accentCoralDark.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Center(
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
                            style: TextStyle(fontFamily: 'Nunito',
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
                      style: TextStyle(fontFamily: 'Nunito',
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
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _signInWithGoogle,
                  child: SvgPicture.asset(
                    _isLogin
                        ? 'lib/images/licensed/svg/google-logo-sign-in.svg'
                        : 'lib/images/licensed/svg/google-logo-sign-up.svg',
                    height: 40,
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
                      style: TextStyle(fontFamily: 'Nunito',
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
      ),
    );
  }
}
