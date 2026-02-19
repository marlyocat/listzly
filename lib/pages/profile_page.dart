import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:listzly/models/profile.dart';
import 'package:listzly/models/user_role.dart';
import 'package:listzly/models/user_settings.dart';
import 'package:listzly/pages/intro_page.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/settings_provider.dart';
import 'package:listzly/providers/instrument_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/services/notification_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final settingsAsync = ref.watch(userSettingsNotifierProvider);
    final instrumentsAsync = ref.watch(instrumentStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Profile',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Profile card
            SliverToBoxAdapter(
              child: profileAsync.when(
                data: (profile) {
                  final email = ref.watch(currentUserProvider)?.email;
                  return _buildProfileCard(profile, email);
                },
                loading: () => _buildProfileCardLoading(),
                error: (err, _) => _buildErrorCard('Failed to load profile'),
              ),
            ),

            // Role & Group section
            SliverToBoxAdapter(
              child: profileAsync.when(
                data: (profile) =>
                    _buildRoleGroupSection(context, ref, profile),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Display section
            SliverToBoxAdapter(
              child: settingsAsync.when(
                data: (settings) => _buildDisplaySection(ref, settings),
                loading: () => _buildSectionLoading('Display'),
                error: (err, _) =>
                    _buildErrorCard('Failed to load display settings'),
              ),
            ),

            // Practice section
            SliverToBoxAdapter(
              child: settingsAsync.when(
                data: (settings) => _buildPracticeSection(context, ref, settings),
                loading: () => _buildSectionLoading('Practice'),
                error: (err, _) =>
                    _buildErrorCard('Failed to load practice settings'),
              ),
            ),

            // Instruments section
            SliverToBoxAdapter(
              child: instrumentsAsync.when(
                data: (instruments) => _buildInstrumentsSection(instruments),
                loading: () => _buildSectionLoading('My Instruments'),
                error: (err, _) =>
                    _buildErrorCard('Failed to load instruments'),
              ),
            ),

            // Log Out button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          transitionDuration:
                              const Duration(milliseconds: 600),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 300),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const IntroPage(),
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            if (animation.status == AnimationStatus.reverse) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            }
                            return TurnPageTransition(
                              animation: animation,
                              overleafColor: primaryDark,
                              animationTransitionPoint: 0.5,
                              direction: TurnDirection.leftToRight,
                              child: child,
                            );
                          },
                        ),
                        (route) => false,
                      );
                      NotificationService.instance.cancelReminder();
                      ref.read(authServiceProvider).signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkCardBg,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.black, width: 5),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Log Out',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom spacing for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ─── Profile card ─────────────────────────────────────────────────
  Widget _buildProfileCard(Profile profile, String? email) {
    final joinDate = _formatMonthYear(profile.createdAt);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: heroCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: darkSurfaceBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            // Name + email + join date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkTextMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Joined $joinDate',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: darkTextSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentCoral.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: accentCoral.withAlpha(60)),
                        ),
                        child: Text(
                          profile.role.displayName,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accentCoral,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCardLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: heroCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: const Center(
          child: SizedBox(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(color: primaryLight),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Role & Group section ─────────────────────────────────────
  Widget _buildRoleGroupSection(
      BuildContext context, WidgetRef ref, Profile profile) {
    final items = <_SettingsRow>[];

    if (profile.isTeacher) {
      final groupAsync = ref.watch(teacherGroupProvider);
      final studentsAsync = ref.watch(teacherStudentsProvider);
      final studentCount = studentsAsync.valueOrNull?.length ?? 0;
      final inviteCode = groupAsync.valueOrNull?.inviteCode;

      if (inviteCode != null) {
        items.add(_SettingsRow(
          icon: Icons.vpn_key_rounded,
          label: 'Invite Code',
          trailing: _TrailingText(inviteCode),
          onTap: () {
            Clipboard.setData(ClipboardData(text: inviteCode));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invite code copied!',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                backgroundColor: accentCoral,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ));
        items.add(_SettingsRow(
          icon: Icons.qr_code_rounded,
          label: 'Show QR Code',
          trailing: const _TrailingText(''),
          onTap: () => _showQrCode(context, inviteCode),
        ));
      }

      items.add(_SettingsRow(
        icon: Icons.group_rounded,
        label: 'Students',
        trailing: _TrailingText('$studentCount/20'),
      ));

      items.add(_SettingsRow(
        icon: Icons.swap_horiz_rounded,
        label: 'Change Role',
        trailing: const _TrailingText('Teacher'),
        onTap: () => _showRoleChangePicker(context, ref, profile,
            hasStudents: studentCount > 0),
      ));
    } else if (profile.isStudent) {
      final membershipAsync = ref.watch(studentMembershipProvider);
      final isInGroup = membershipAsync.valueOrNull != null;

      if (isInGroup) {
        items.add(_SettingsRow(
          icon: Icons.school_rounded,
          label: 'Your Group',
          trailing: const _TrailingText('Joined'),
        ));
        items.add(_SettingsRow(
          icon: Icons.exit_to_app_rounded,
          label: 'Leave Group',
          trailing: const _TrailingText(''),
          onTap: () => _showLeaveGroupDialog(context, ref),
        ));
        items.add(_SettingsRow(
          icon: Icons.swap_horiz_rounded,
          label: 'Change Role',
          trailing: const _TrailingText('Leave group first'),
        ));
      } else {
        items.add(_SettingsRow(
          icon: Icons.group_add_rounded,
          label: 'Join a Group',
          trailing: const _TrailingText('Enter code'),
          onTap: () => _showJoinGroupDialog(context, ref),
        ));
        items.add(_SettingsRow(
          icon: Icons.swap_horiz_rounded,
          label: 'Change Role',
          trailing: _TrailingText(profile.role.displayName),
          onTap: () => _showRoleChangePicker(context, ref, profile),
        ));
      }
    } else {
      // Self-Learner
      items.add(_SettingsRow(
        icon: Icons.swap_horiz_rounded,
        label: 'Change Role',
        trailing: _TrailingText(profile.role.displayName),
        onTap: () => _showRoleChangePicker(context, ref, profile),
      ));
    }

    return _buildSettingsSection(title: 'Role & Group', items: items);
  }

  void _showRoleChangePicker(
      BuildContext context, WidgetRef ref, Profile profile,
      {bool hasStudents = false}) {
    final roles = [
      (UserRole.selfLearner, 'Self-Learner', 'Practice on your own'),
      (UserRole.student, 'Student', 'Join a teacher\'s group'),
      (UserRole.teacher, 'Teacher', 'Manage students'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E0E3D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Colors.black, width: 5),
              left: BorderSide(color: Colors.black, width: 5),
              right: BorderSide(color: Colors.black, width: 5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: darkTextMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Role',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (hasStudents) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Warning: Changing your role will disband your group and remove all students.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentCoralDark,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ...roles.map((r) {
                  final (role, name, desc) = r;
                  final isSelected = role == profile.role;
                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (role == profile.role) return;
                      await _changeRole(context, ref, role,
                          hasStudents: hasStudents);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: darkDivider),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? primaryLight
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  desc,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: darkTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_rounded,
                                color: primaryLight, size: 22),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeRole(
      BuildContext context, WidgetRef ref, UserRole newRole,
      {bool hasStudents = false}) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final profileService = ref.read(profileServiceProvider);
      final groupService = ref.read(groupServiceProvider);

      // If switching away from teacher and has students, disband group
      if (hasStudents) {
        final group = await groupService.getTeacherGroup(user.id);
        if (group != null) {
          await groupService.deleteGroup(group.id);
        }
      }

      // If switching to teacher, create a group
      if (newRole == UserRole.teacher) {
        await groupService.createGroup(user.id);
      }

      await profileService.updateProfile(user.id, role: newRole);

      ref.invalidate(currentProfileProvider);
      ref.invalidate(teacherGroupProvider);
      ref.invalidate(teacherStudentsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change role: $e'),
            backgroundColor: accentCoralDark,
          ),
        );
      }
    }
  }

  void _showLeaveGroupDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0E3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Leave Group',
          style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to leave your teacher\'s group?',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: darkTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: darkTextMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              await ref.read(groupServiceProvider).leaveGroup(user.id);
              ref.invalidate(studentMembershipProvider);
              ref.invalidate(isInGroupProvider);
            },
            child: Text('Leave',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: accentCoralDark)),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E0E3D),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Join a Group',
            style:
                GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your teacher\'s invite code',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'INVITE CODE',
                  hintStyle: GoogleFonts.nunito(
                    color: darkTextMuted.withAlpha(100),
                    fontWeight: FontWeight.w600,
                  ),
                  errorText: errorText,
                  filled: true,
                  fillColor: Colors.white.withAlpha(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: accentCoral, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final scanned = await Navigator.of(ctx).push<String>(
                    MaterialPageRoute(builder: (_) => const _QrScannerPage()),
                  );
                  if (scanned != null && scanned.isNotEmpty) {
                    codeController.text = scanned;
                    setDialogState(() => errorText = null);
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: darkTextMuted)),
            ),
            TextButton(
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.isEmpty) {
                  setDialogState(() => errorText = 'Please enter a code');
                  return;
                }
                final user = ref.read(currentUserProvider);
                if (user == null) return;
                final groupService = ref.read(groupServiceProvider);
                final group = await groupService.findGroupByInviteCode(code);
                if (group == null) {
                  setDialogState(() => errorText = 'Invalid invite code');
                  return;
                }
                try {
                  await groupService.joinGroup(user.id, group.id);
                  ref.invalidate(studentMembershipProvider);
                  ref.invalidate(isInGroupProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setDialogState(() => errorText = e.toString());
                }
              },
              child: Text('Join',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: primaryLight)),
            ),
          ],
        ),
      ),
    );
  }

  void _showQrCode(BuildContext context, String inviteCode) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E0E3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan to Join',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Students can scan this QR code\nto join your group',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: inviteCode,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  inviteCode,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    color: accentCoral,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Display settings section ───────────────────────────────────
  Widget _buildDisplaySection(WidgetRef ref, UserSettings settings) {
    return const SizedBox.shrink();
  }

  // ─── Practice settings section ──────────────────────────────────
  Widget _buildPracticeSection(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    return _buildSettingsSection(
      title: 'Practice',
      items: [
        _SettingsRow(
          icon: Icons.timer_outlined,
          label: 'Daily Goal',
          trailing: _TrailingText('${settings.dailyGoalMinutes} min'),
          onTap: () => _showDailyGoalPicker(context, ref, settings),
        ),
        _SettingsRow(
          icon: Icons.notifications_outlined,
          label: 'Reminders',
          trailing: _TrailingText(
            settings.reminderTime != null
                ? _formatReminderDisplay(settings.reminderTime!)
                : 'Off',
          ),
          onTap: () => _showReminderPicker(context, ref, settings),
        ),
      ],
    );
  }

  void _showDailyGoalPicker(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    const goalOptions = [5, 10, 15, 20, 30, 45, 60];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E0E3D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Colors.black, width: 5),
              left: BorderSide(color: Colors.black, width: 5),
              right: BorderSide(color: Colors.black, width: 5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: darkTextMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Daily Goal',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How long do you want to practice each day?',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ...goalOptions.map((minutes) {
                  final isSelected = minutes == settings.dailyGoalMinutes;
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(userSettingsNotifierProvider.notifier)
                          .updateSetting('daily_goal_minutes', minutes);
                      Navigator.pop(ctx);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: darkDivider,
                            width: goalOptions.first == minutes ? 0 : 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '$minutes min',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w600,
                              color:
                                  isSelected ? primaryLight : Colors.white,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: primaryLight,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Reminder picker ─────────────────────────────────────────────
  void _showReminderPicker(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    const hours = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    const minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
    const periods = ['AM', 'PM'];

    // Parse current reminder time to set initial wheel positions
    int initialHourIndex = 0; // default 12
    int initialMinuteIndex = 0; // default :00
    int initialPeriodIndex = 0; // default AM
    if (settings.reminderTime != null) {
      final parts = settings.reminderTime!.split(':');
      final h24 = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      initialPeriodIndex = h24 >= 12 ? 1 : 0;
      final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
      initialHourIndex = hours.indexOf(h12);
      initialMinuteIndex = (m ~/ 5).clamp(0, 11);
      if (initialHourIndex < 0) initialHourIndex = 0;
    }

    int selectedHourIndex = initialHourIndex;
    int selectedMinuteIndex = initialMinuteIndex;
    int selectedPeriodIndex = initialPeriodIndex;

    const wheelHeight = 200.0;
    const itemExtent = 42.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E0E3D),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  top: BorderSide(color: Colors.black, width: 5),
                  left: BorderSide(color: Colors.black, width: 5),
                  right: BorderSide(color: Colors.black, width: 5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: darkTextMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Practice Reminder',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'When should we remind you to practice?',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Scroll wheel picker
                    SizedBox(
                      height: wheelHeight,
                      child: Stack(
                        children: [
                          // Selection highlight band
                          Center(
                            child: Container(
                              height: itemExtent,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 24),
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
                                      initialItem: initialHourIndex),
                                  itemExtent: itemExtent,
                                  physics:
                                      const FixedExtentScrollPhysics(),
                                  diameterRatio: 1.5,
                                  perspective: 0.003,
                                  onSelectedItemChanged: (index) {
                                    setSheetState(() =>
                                        selectedHourIndex = index);
                                  },
                                  childDelegate:
                                      ListWheelChildBuilderDelegate(
                                    childCount: hours.length,
                                    builder: (context, index) {
                                      final isSelected =
                                          index == selectedHourIndex;
                                      return Center(
                                        child: Text(
                                          '${hours[index]}',
                                          style: GoogleFonts.nunito(
                                            fontSize: isSelected ? 22 : 18,
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
                                      initialItem: initialMinuteIndex),
                                  itemExtent: itemExtent,
                                  physics:
                                      const FixedExtentScrollPhysics(),
                                  diameterRatio: 1.5,
                                  perspective: 0.003,
                                  onSelectedItemChanged: (index) {
                                    setSheetState(() =>
                                        selectedMinuteIndex = index);
                                  },
                                  childDelegate:
                                      ListWheelChildBuilderDelegate(
                                    childCount: minutes.length,
                                    builder: (context, index) {
                                      final isSelected =
                                          index == selectedMinuteIndex;
                                      return Center(
                                        child: Text(
                                          minutes[index]
                                              .toString()
                                              .padLeft(2, '0'),
                                          style: GoogleFonts.nunito(
                                            fontSize: isSelected ? 22 : 18,
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
                                      initialItem: initialPeriodIndex),
                                  itemExtent: itemExtent,
                                  physics:
                                      const FixedExtentScrollPhysics(),
                                  diameterRatio: 1.5,
                                  perspective: 0.003,
                                  onSelectedItemChanged: (index) {
                                    setSheetState(() =>
                                        selectedPeriodIndex = index);
                                  },
                                  childDelegate:
                                      ListWheelChildBuilderDelegate(
                                    childCount: periods.length,
                                    builder: (context, index) {
                                      final isSelected =
                                          index == selectedPeriodIndex;
                                      return Center(
                                        child: Text(
                                          periods[index],
                                          style: GoogleFonts.nunito(
                                            fontSize: isSelected ? 22 : 18,
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

                    const SizedBox(height: 20),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Turn off button
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.pop(ctx);
                                await _clearReminder(ref);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: darkCardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.black, width: 3),
                                ),
                                child: Center(
                                  child: Text(
                                    'Turn Off',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Set button
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                // Convert 12h to 24h
                                final h12 = hours[selectedHourIndex];
                                final m = minutes[selectedMinuteIndex];
                                final isAM = selectedPeriodIndex == 0;
                                int h24;
                                if (h12 == 12) {
                                  h24 = isAM ? 0 : 12;
                                } else {
                                  h24 = isAM ? h12 : h12 + 12;
                                }
                                final timeStr =
                                    '${h24.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
                                Navigator.pop(ctx);
                                await _setReminder(ref, timeStr);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: primaryLight,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.black, width: 3),
                                ),
                                child: Center(
                                  child: Text(
                                    'Set Reminder',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatReminderDisplay(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  Future<void> _setReminder(WidgetRef ref, String timeStr) async {
    ref
        .read(userSettingsNotifierProvider.notifier)
        .updateSetting('reminder_time', timeStr);
    final granted = await NotificationService.instance.requestPermission();
    if (granted) {
      await NotificationService.instance.scheduleDailyReminder(timeStr);
    }
  }

  Future<void> _clearReminder(WidgetRef ref) async {
    ref
        .read(userSettingsNotifierProvider.notifier)
        .updateSetting('reminder_time', null);
    await NotificationService.instance.cancelReminder();
  }

  // ─── Generic settings section ─────────────────────────────────────
  Widget _buildSettingsSection({
    required String title,
    required List<_SettingsRow> items,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkTextSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: darkCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 5),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: darkDivider,
                      ),
                    GestureDetector(
                      onTap: row.onTap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Icon(
                              row.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                row.label,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            row.trailing.build(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Instruments section ──────────────────────────────────────────
  Widget _buildInstrumentsSection(List<Map<String, dynamic>> instruments) {
    final totalMinutes = instruments.fold<int>(
        0, (sum, i) => sum + ((i['minutes'] as num?)?.toInt() ?? 0));

    // Map of instrument names to icons and colors for display purposes
    const instrumentIcons = <String, IconData>{
      'Piano': Icons.piano_rounded,
      'Guitar': Icons.music_note_rounded,
      'Violin': Icons.music_note_outlined,
      'Drums': Icons.surround_sound_rounded,
    };
    const instrumentColors = <String, Color>{
      'Piano': primaryColor,
      'Guitar': Color(0xFFD4A056),
      'Violin': accentCoral,
      'Drums': Color(0xFF5B9A6B),
    };
    const defaultIcon = Icons.music_note_rounded;
    const defaultColor = primaryLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'My Instruments',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkTextSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: darkCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 5),
            ),
            child: instruments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Center(
                      child: Text(
                        'No instruments yet',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkTextSecondary,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: instruments.asMap().entries.map((entry) {
                      final i = entry.key;
                      final inst = entry.value;
                      final name = (inst['name'] as String?) ?? 'Unknown';
                      final minutes =
                          (inst['minutes'] as num?)?.toInt() ?? 0;
                      final sessions =
                          (inst['sessions'] as num?)?.toInt() ?? 0;
                      final icon = instrumentIcons[name] ?? defaultIcon;
                      final color = instrumentColors[name] ?? defaultColor;
                      final fraction =
                          totalMinutes > 0 ? minutes / totalMinutes : 0.0;

                      return Column(
                        children: [
                          if (i > 0)
                            const Divider(
                              height: 1,
                              indent: 60,
                              endIndent: 16,
                              color: darkDivider,
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: darkSurfaceBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: Icon(icon,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.nunito(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(3),
                                        child: SizedBox(
                                          height: 6,
                                          child: Stack(
                                            children: [
                                              Container(
                                                  color: darkProgressBg),
                                              FractionallySizedBox(
                                                widthFactor: fraction
                                                    .clamp(0.0, 1.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$minutes min',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '$sessions sessions',
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: darkTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Loading placeholder for a section ────────────────────────────
  Widget _buildSectionLoading(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkTextSecondary,
              ),
            ),
          ),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: darkCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 5),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error card ───────────────────────────────────────────────────
  Widget _buildErrorCard(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: Center(
          child: Text(
            message,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accentCoral,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Utility ──────────────────────────────────────────────────────
  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ─── Settings row model + trailing widgets ──────────────────────────
class _SettingsRow {
  final IconData icon;
  final String label;
  final _Trailing trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });
}

abstract class _Trailing {
  const _Trailing();
  Widget build();
}

class _TrailingText extends _Trailing {
  final String text;
  const _TrailingText(this.text);

  @override
  Widget build() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkTextSecondary,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: darkTextMuted, size: 20),
      ],
    );
  }
}

// ─── QR Scanner Page ──────────────────────────────────────────────
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

