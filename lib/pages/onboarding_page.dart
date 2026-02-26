import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:listzly/models/user_role.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/providers/settings_provider.dart';
import 'package:listzly/pages/home_page.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/services/notification_service.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 1: Role
  UserRole _selectedRole = UserRole.selfLearner;
  final _inviteCodeController = TextEditingController();

  // Step 2: Daily goal
  int _selectedGoalMinutes = 15;

  // Step 3: Reminder
  bool _reminderEnabled = false;
  int _selectedHourIndex = 0; // 12
  int _selectedMinuteIndex = 0; // :00
  int _selectedPeriodIndex = 0; // AM

  bool _isLoading = false;
  String? _errorMessage;

  static const _hours = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  static const _minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
  static const _periods = ['AM', 'PM'];
  static const _goalOptions = [5, 10, 15, 20, 30, 45, 60, 90, 120];

  @override
  void dispose() {
    _pageController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validate step 1 before advancing
    if (_currentPage == 0 && _selectedRole == UserRole.student) {
      final code = _inviteCodeController.text.trim();
      if (code.isEmpty) {
        setState(() => _errorMessage = 'Please enter an invite code');
        return;
      }
    }
    setState(() => _errorMessage = null);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    setState(() => _errorMessage = null);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profileService = ref.read(profileServiceProvider);
      final groupService = ref.read(groupServiceProvider);
      final settingsService = ref.read(settingsServiceProvider);

      // Handle role-specific logic
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
          // Go back to step 1 to show error
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut);
          return;
        }
        await groupService.joinGroup(user.id, group.id,
            teacherId: group.teacherId);
      } else if (_selectedRole == UserRole.teacher) {
        await groupService.createGroup(user.id);
      }

      // Save role
      await profileService.updateProfile(
        user.id,
        role: _selectedRole,
        roleSelected: true,
      );

      // Save daily goal + reminder
      final settingsUpdates = <String, dynamic>{
        'daily_goal_minutes': _selectedGoalMinutes,
      };

      if (_reminderEnabled) {
        final h12 = _hours[_selectedHourIndex];
        final m = _minutes[_selectedMinuteIndex];
        final isAM = _selectedPeriodIndex == 0;
        int h24;
        if (h12 == 12) {
          h24 = isAM ? 0 : 12;
        } else {
          h24 = isAM ? h12 : h12 + 12;
        }
        final timeStr =
            '${h24.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        settingsUpdates['reminder_time'] = timeStr;
        await NotificationService.instance.scheduleDailyReminder(timeStr);
      }

      await settingsService.updateSettings(user.id, settingsUpdates);

      ref.invalidate(currentProfileProvider);
      ref.invalidate(userSettingsNotifierProvider);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          _turnPageRoute(const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      setState(() {
        if (msg.contains('already in a group')) {
          _errorMessage = 'You are already in a group. Leave it first.';
        } else if (msg.contains('full') || msg.contains('max')) {
          _errorMessage =
              'This group is full. Ask your teacher to upgrade their plan.';
        } else {
          _errorMessage = 'Could not join group. Please try again.';
        }
      });
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
        child: Column(
          children: [
            // Top section: brand + progress
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, accentCoral],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Listzly',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Step indicator
                  Row(
                    children: List.generate(3, (i) {
                      final isActive = i == _currentPage;
                      final isPast = i < _currentPage;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? accentCoral
                              : isPast
                                  ? accentCoral.withAlpha(100)
                                  : Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildRolePage(),
                  _buildGoalPage(),
                  _buildReminderPage(),
                ],
              ),
            ),

            // Bottom navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Row(
                children: [
                  // Back button
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _previousPage,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: Colors.white.withAlpha(25),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),

                  // Next / Get Started button
                  Expanded(
                    child: SizedBox(
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
                          onPressed: _isLoading
                              ? null
                              : (_currentPage < 2 ? _nextPage : _finish),
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
                                  _currentPage < 2 ? 'Next' : 'Get Started',
                                  style: GoogleFonts.nunito(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 1: Role Selection ─────────────────────────────────────
  Widget _buildRolePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // Self-Learner
          _RoleCard(
            icon: Icons.music_note_rounded,
            title: 'Self-Learner',
            description: 'I practice on my own',
            isSelected: _selectedRole == UserRole.selfLearner,
            onTap: () => setState(() {
              _selectedRole = UserRole.selfLearner;
              _errorMessage = null;
            }),
          ),
          const SizedBox(height: 16),

          // Student
          _RoleCard(
            icon: Icons.school_rounded,
            title: 'Student',
            description: 'I have a teacher',
            isSelected: _selectedRole == UserRole.student,
            onTap: () => setState(() {
              _selectedRole = UserRole.student;
              _errorMessage = null;
            }),
          ),
          const SizedBox(height: 16),

          // Teacher
          _RoleCard(
            icon: Icons.groups_rounded,
            title: 'Teacher',
            description: 'I manage students',
            isSelected: _selectedRole == UserRole.teacher,
            onTap: () => setState(() {
              _selectedRole = UserRole.teacher;
              _errorMessage = null;
            }),
          ),

          // Invite code (Student only)
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
                prefixIcon: const Icon(Icons.vpn_key_rounded,
                    color: darkTextMuted, size: 20),
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
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final scanned = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const _QrScannerPage()),
                );
                if (scanned != null && scanned.isNotEmpty) {
                  _inviteCodeController.text = scanned;
                  setState(() => _errorMessage = null);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded,
                      color: primaryLight, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Scan QR Code',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Error message
          if (_errorMessage != null && _currentPage == 0) ...[
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Step 2: Daily Goal ─────────────────────────────────────────
  Widget _buildGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Daily Practice Goal',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How long do you want to practice each day?',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: darkTextSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Goal option grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _goalOptions.map((minutes) {
              final isSelected = minutes == _selectedGoalMinutes;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoalMinutes = minutes),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: (MediaQuery.of(context).size.width - 56 - 24) / 3,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentCoral.withAlpha(20)
                        : Colors.white.withAlpha(8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? accentCoral : Colors.white.withAlpha(20),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$minutes',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 28,
                          color: isSelected ? accentCoral : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'minutes',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? accentCoral : darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Step 3: Reminders ──────────────────────────────────────────
  Widget _buildReminderPage() {
    const wheelHeight = 200.0;
    const itemExtent = 42.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Stay on Track',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get a daily reminder to practice',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: darkTextSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Reminder toggle card
          GestureDetector(
            onTap: () async {
              if (!_reminderEnabled) {
                final granted =
                    await NotificationService.instance.requestPermission();
                if (!granted) return;
              }
              setState(() => _reminderEnabled = !_reminderEnabled);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _reminderEnabled
                    ? accentCoral.withAlpha(20)
                    : Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _reminderEnabled
                      ? accentCoral
                      : Colors.white.withAlpha(20),
                  width: _reminderEnabled ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _reminderEnabled
                          ? accentCoral.withAlpha(40)
                          : Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color:
                          _reminderEnabled ? accentCoral : darkTextSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Reminder',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _reminderEnabled
                                ? Colors.white
                                : darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Never miss a practice session',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: darkTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _reminderEnabled
                          ? accentCoral
                          : Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: _reminderEnabled
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Time picker (visible when reminder is enabled)
          if (_reminderEnabled) ...[
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Remind me at',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: wheelHeight,
                    child: Stack(
                      children: [
                        // Selection highlight band
                        Center(
                          child: Container(
                            height: itemExtent,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Wheels
                        Row(
                          children: [
                            const SizedBox(width: 24),
                            // Hour wheel
                            Expanded(
                              flex: 3,
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(
                                    initialItem: _selectedHourIndex),
                                itemExtent: itemExtent,
                                physics: const FixedExtentScrollPhysics(),
                                diameterRatio: 1.5,
                                perspective: 0.003,
                                onSelectedItemChanged: (index) {
                                  setState(
                                      () => _selectedHourIndex = index);
                                },
                                childDelegate:
                                    ListWheelChildBuilderDelegate(
                                  childCount: _hours.length,
                                  builder: (context, index) {
                                    final isSelected =
                                        index == _selectedHourIndex;
                                    return Center(
                                      child: Text(
                                        '${_hours[index]}',
                                        style: GoogleFonts.nunito(
                                          fontSize:
                                              isSelected ? 22 : 18,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : darkTextSecondary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Minute wheel
                            Expanded(
                              flex: 3,
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(
                                    initialItem: _selectedMinuteIndex),
                                itemExtent: itemExtent,
                                physics: const FixedExtentScrollPhysics(),
                                diameterRatio: 1.5,
                                perspective: 0.003,
                                onSelectedItemChanged: (index) {
                                  setState(
                                      () => _selectedMinuteIndex = index);
                                },
                                childDelegate:
                                    ListWheelChildBuilderDelegate(
                                  childCount: _minutes.length,
                                  builder: (context, index) {
                                    final isSelected =
                                        index == _selectedMinuteIndex;
                                    return Center(
                                      child: Text(
                                        _minutes[index]
                                            .toString()
                                            .padLeft(2, '0'),
                                        style: GoogleFonts.nunito(
                                          fontSize:
                                              isSelected ? 22 : 18,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : darkTextSecondary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // AM/PM wheel
                            Expanded(
                              flex: 3,
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(
                                    initialItem: _selectedPeriodIndex),
                                itemExtent: itemExtent,
                                physics: const FixedExtentScrollPhysics(),
                                diameterRatio: 1.5,
                                perspective: 0.003,
                                onSelectedItemChanged: (index) {
                                  setState(
                                      () => _selectedPeriodIndex = index);
                                },
                                childDelegate:
                                    ListWheelChildBuilderDelegate(
                                  childCount: _periods.length,
                                  builder: (context, index) {
                                    final isSelected =
                                        index == _selectedPeriodIndex;
                                    return Center(
                                      child: Text(
                                        _periods[index],
                                        style: GoogleFonts.nunito(
                                          fontSize:
                                              isSelected ? 22 : 18,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : darkTextSecondary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],

          // Error message
          if (_errorMessage != null && _currentPage == 2) ...[
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Role Card ──────────────────────────────────────────────────────
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
              const Icon(Icons.check_circle_rounded,
                  color: accentCoral, size: 24),
          ],
        ),
      ),
    );
  }
}

// ─── QR Scanner Page ────────────────────────────────────────────────
class _QrScannerPage extends StatefulWidget {
  const _QrScannerPage();

  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF150833),
        foregroundColor: Colors.white,
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_scanned) return;
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            _scanned = true;
            Navigator.of(context).pop(barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}
