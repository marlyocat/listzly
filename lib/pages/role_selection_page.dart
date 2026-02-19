import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:listzly/models/user_role.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/pages/home_page.dart';
import 'package:listzly/theme/colors.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  UserRole _selectedRole = UserRole.selfLearner;
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profileService = ref.read(profileServiceProvider);
      final groupService = ref.read(groupServiceProvider);

      if (_selectedRole == UserRole.student) {
        final code = _inviteCodeController.text.trim();
        if (code.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter an invite code';
            _isLoading = false;
          });
          return;
        }

        final group = await groupService.findGroupByInviteCode(code);
        if (group == null) {
          setState(() {
            _errorMessage = 'Invalid invite code';
            _isLoading = false;
          });
          return;
        }

        await groupService.joinGroup(user.id, group.id);
      }

      await profileService.updateProfile(
        user.id,
        role: _selectedRole,
        roleSelected: true,
      );

      ref.invalidate(currentProfileProvider);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          _turnPageRoute(const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
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
                  'Listzly',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Choose Your Role',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How will you use Listzly?',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: darkTextSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Self-Learner card
              _RoleCard(
                icon: Icons.music_note_rounded,
                title: 'Self-Learner',
                description: 'I practice on my own',
                isSelected: _selectedRole == UserRole.selfLearner,
                onTap: () => setState(() => _selectedRole = UserRole.selfLearner),
              ),

              const SizedBox(height: 16),

              // Student card
              _RoleCard(
                icon: Icons.school_rounded,
                title: 'Student',
                description: 'I have a teacher',
                isSelected: _selectedRole == UserRole.student,
                onTap: () => setState(() => _selectedRole = UserRole.student),
              ),

              // Invite code field (visible when Student is selected)
              if (_selectedRole == UserRole.student) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _inviteCodeController,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Invite Code',
                    labelStyle: GoogleFonts.nunito(
                      color: darkTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon:
                        const Icon(Icons.vpn_key_rounded, color: darkTextMuted, size: 20),
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
                    hintText: 'Enter your teacher\'s code',
                    hintStyle: GoogleFonts.nunito(
                      color: darkTextMuted.withAlpha(100),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.nunito(
                    color: accentCoralDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Continue button
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
                    onPressed: _isLoading ? null : _continue,
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
                            'Continue',
                            style: GoogleFonts.nunito(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? accentCoral.withAlpha(20)
              : Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentCoral : Colors.white.withAlpha(20),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? accentCoral.withAlpha(40)
                    : Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? accentCoral : darkTextSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: darkTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: accentCoral, size: 24),
          ],
        ),
      ),
    );
  }
}
