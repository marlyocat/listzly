import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:listzly/models/profile.dart';
import 'package:listzly/models/user_role.dart';
import 'package:listzly/models/user_settings.dart';
import 'package:listzly/pages/auth_page.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/settings_provider.dart';
import 'package:listzly/providers/instrument_provider.dart';
import 'package:listzly/models/student_summary.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/level_utils.dart';
import 'package:listzly/utils/responsive.dart';
import 'package:listzly/services/notification_service.dart';
import 'package:listzly/providers/subscription_provider.dart';
import 'package:listzly/models/subscription_info.dart';
import 'package:listzly/pages/paywall_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final settingsAsync = ref.watch(userSettingsProvider);
    final instrumentsAsync = ref.watch(instrumentStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Title
            SliverContentConstraint(
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
            SliverContentConstraint(
              child: profileAsync.when(
                data: (profile) {
                  final email = ref.watch(currentUserProvider)?.email;
                  return _buildProfileCard(profile, email);
                },
                loading: () => _buildProfileCardLoading(),
                error: (err, _) => _buildErrorCard('Failed to load profile'),
              ),
            ),

            // Subscription section
            SliverContentConstraint(
              child: _buildSubscriptionSection(context, ref),
            ),

            // Role & Group section
            SliverContentConstraint(
              child: profileAsync.when(
                data: (profile) =>
                    _buildRoleGroupSection(context, ref, profile),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            // Display section
            SliverContentConstraint(
              child: settingsAsync.when(
                data: (settings) => _buildDisplaySection(ref, settings),
                loading: () => _buildSectionLoading('Display'),
                error: (err, _) =>
                    _buildErrorCard('Failed to load display settings'),
              ),
            ),

            // Practice section
            SliverContentConstraint(
              child: settingsAsync.when(
                data: (settings) => _buildPracticeSection(context, ref, settings),
                loading: () => _buildSectionLoading('Practice'),
                error: (err, _) =>
                    _buildErrorCard('Failed to load practice settings'),
              ),
            ),

            // Instruments section
            SliverContentConstraint(
              child: instrumentsAsync.when(
                data: (instruments) => _buildInstrumentsSection(instruments),
                loading: () => _buildSectionLoading('My Instruments'),
                error: (err, _) =>
                    _buildErrorCard('Failed to load instruments'),
              ),
            ),

            // Support section
            SliverContentConstraint(
              child: _buildSupportSection(),
            ),

            // Log Out button
            SliverContentConstraint(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1E0E3D),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text(
                            'Log Out?',
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: 20, color: Colors.white),
                          ),
                          content: Text(
                            'Are you sure you want to log out?',
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: darkTextSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancel',
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w700,
                                      color: darkTextMuted)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text('Log Out',
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          transitionDuration:
                              const Duration(milliseconds: 600),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 300),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const AuthPage(),
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
            const SliverContentConstraint(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ─── Subscription section ─────────────────────────────────────────
  Widget _buildSubscriptionSection(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(effectiveSubscriptionTierProvider);

    final Widget card;
    if (tier.isFree) {
      card = _buildFreeSubscriptionCard(context);
    } else {
      final infoAsync = ref.watch(subscriptionInfoProvider);
      card = infoAsync.when(
        data: (info) => _buildPaidSubscriptionCard(context, ref, info),
        loading: () => _buildSubscriptionLoading(),
        error: (_, _) => _buildPaidSubscriptionCard(
          context,
          ref,
          SubscriptionInfo(tier: tier),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'My Subscription',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkTextSecondary,
              ),
            ),
          ),
          card,
        ],
      ),
    );
  }

  Widget _buildFreeSubscriptionCard(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: darkTextMuted.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.person_rounded,
                  color: darkTextMuted, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free Plan',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Upgrade to unlock all features',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: darkTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaywallPage()),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF4A68E), accentCoralDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Upgrade',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildSubscriptionLoading() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 5),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPaidSubscriptionCard(
    BuildContext context,
    WidgetRef ref,
    SubscriptionInfo info,
  ) {
    final tier = info.tier;
    final isCancelled = info.isCancelled;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: badge + plan name + trial badge
          Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentCoral.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: accentCoral, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tier.displayName} Plan',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tier.isTeacherPlan
                            ? 'Full teacher access'
                            : 'You have full access',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (info.isInTrial)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF22C55E).withAlpha(80)),
                    ),
                    child: Text(
                      'Trial',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withAlpha(15),
            ),
            const SizedBox(height: 16),

            // Status row
            Row(
              children: [
                Icon(
                  isCancelled
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isCancelled
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF22C55E),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isCancelled ? 'Cancelled' : 'Active',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isCancelled
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),

            // Expiration / renewal date
            if (info.expirationDate != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: darkTextMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCancelled
                        ? 'Access until ${_formatDate(info.expirationDate!)}'
                        : 'Renews ${_formatDate(info.expirationDate!)}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: darkTextMuted,
                    ),
                  ),
                ],
              ),
            ],

            // Cancellation note
            if (isCancelled && info.expirationDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFFBBF24).withAlpha(40)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFFFBBF24), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your features will remain active until ${_formatDate(info.expirationDate!)}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFBBF24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PaywallPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Change Plan',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isCancelled) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showCancelDialog(context, ref, info),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel Subscription',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionInfo info,
  ) async {
    final expirationText = info.expirationDate != null
        ? ' until ${_formatDate(info.expirationDate!)}'
        : '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0E3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Subscription?',
          style:
              GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
        ),
        content: Text(
          'Your subscription will not renew, but you\'ll keep all your features$expirationText.',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: darkTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep Subscription',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: darkTextMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cancel Subscription',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFBBF24))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Open the platform's subscription management page
    final url = info.managementURL;
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    // Refresh subscription info when user returns
    ref.invalidate(subscriptionInfoProvider);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ─── Support section ──────────────────────────────────────────────
  Widget _buildSupportSection() {
    return _buildSettingsSection(
      title: 'Support',
      items: [
        _SettingsRow(
          icon: Icons.mail_outline_rounded,
          label: 'Contact Support',
          trailing: const _TrailingText(''),
          onTap: () => launchUrl(
            Uri.parse(
                'mailto:help.caplock@gmail.com?subject=Listzly%20Support'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
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
      final studentCount = studentsAsync.value?.length ?? 0;
      final inviteCode = groupAsync.value?.inviteCode;

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
                backgroundColor: accentCoralDark,
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
        onTap: () => _showStudentListSheet(context, ref),
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
      final isInGroup = membershipAsync.value != null;

      if (isInGroup) {
        final membership = membershipAsync.value!;
        items.add(_SettingsRow(
          icon: Icons.school_rounded,
          label: 'Your Group',
          trailing: const _TrailingText('Joined'),
          onTap: () => _showGroupInfoDialog(context, ref, membership.groupId),
        ));
        items.add(_SettingsRow(
          icon: Icons.swap_horiz_rounded,
          label: 'Change Role',
          trailing: const _TrailingText('Student'),
          onTap: () => _showLeaveGroupAndChangeRoleDialog(context, ref, profile),
        ));
        items.add(_SettingsRow(
          icon: Icons.exit_to_app_rounded,
          label: 'Leave Group',
          trailing: const _TrailingText(''),
          labelColor: Colors.red,
          onTap: () => _showLeaveGroupDialog(context, ref),
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
                      if (hasStudents) {
                        final confirmed =
                            await _showDisbandConfirmDialog(context);
                        if (confirmed != true) return;
                      }
                      if (!context.mounted) return;
                      // If switching to student, require invite code first
                      if (role == UserRole.student) {
                        final joined = await _showInviteCodeDialog(
                            context, ref,
                            hasStudents: hasStudents);
                        if (joined != true) return;
                        return;
                      }
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
      rethrow;
    }
  }

  Future<bool?> _showDisbandConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0E3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Disband Group?',
          style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
        ),
        content: Text(
          'Changing your role will permanently disband your group and remove all students. This action cannot be undone.',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: darkTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: darkTextMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Disband & Change Role',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showInviteCodeDialog(BuildContext context, WidgetRef ref,
      {bool hasStudents = false}) {
    final controller = TextEditingController();
    String? errorText;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E0E3D),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Join a Teacher',
            style:
                GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your teacher\'s invite code to join their group.',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
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
                  final scanned = await Navigator.of(ctx).push<String>(
                    MaterialPageRoute(
                        builder: (_) => const _QrScannerPage()),
                  );
                  if (!ctx.mounted) return;
                  if (scanned != null && scanned.isNotEmpty) {
                    controller.text = scanned;
                    setState(() => errorText = null);
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
              if (errorText != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(60)),
                  ),
                  child: Text(
                    errorText!,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: darkTextMuted)),
            ),
            TextButton(
              onPressed: () async {
                final code = controller.text.trim();
                if (code.isEmpty) {
                  setState(() => errorText = 'Please enter an invite code');
                  return;
                }

                try {
                  final groupService = ref.read(groupServiceProvider);
                  final group =
                      await groupService.findGroupByInviteCode(code);
                  if (!ctx.mounted) return;
                  if (group == null) {
                    setState(() => errorText = 'Invalid invite code');
                    return;
                  }

                  final user = ref.read(currentUserProvider);
                  if (user == null) return;

                  final previousRole = ref
                      .read(currentProfileProvider)
                      .value
                      ?.role;

                  // Change role to student first (needed for RLS)
                  if (!ctx.mounted) return;
                  await _changeRole(ctx, ref, UserRole.student,
                      hasStudents: hasStudents);

                  try {
                    // Then join the group
                    await groupService.joinGroup(user.id, group.id,
                        teacherId: group.teacherId);
                    ref.invalidate(studentMembershipProvider);
                    if (ctx.mounted) Navigator.pop(ctx, true);
                  } catch (e) {
                    debugPrint('joinGroup error: $e');
                    // Join failed — revert role
                    if (previousRole != null && ctx.mounted) {
                      try {
                        await _changeRole(ctx, ref, previousRole);
                      } catch (_) {}
                    }
                    final msg = e.toString().toLowerCase();
                    setState(() {
                      if (msg.contains('already in a group')) {
                        errorText =
                            'You are already in a group. Leave it first.';
                      } else if (msg.contains('full') ||
                          msg.contains('max')) {
                        errorText =
                            'This group is full. Ask your teacher to upgrade their plan.';
                      } else {
                        errorText =
                            'Could not join group. Please try again.';
                      }
                    });
                  }
                } catch (e) {
                  debugPrint('invite code dialog error: $e');
                  setState(() => errorText =
                      'Something went wrong. Please try again.');
                }
              },
              child: Text('Join',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: accentCoral)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveGroupAndChangeRoleDialog(
      BuildContext context, WidgetRef ref, Profile profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0E3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Leave Group & Change Role?',
          style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
        ),
        content: Text(
          'You are currently in a group. Changing your role will remove you from your teacher\'s group.',
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
              try {
                final user = ref.read(currentUserProvider);
                if (user == null) return;
                await ref.read(groupServiceProvider).leaveGroup(user.id);
                await ref.read(profileServiceProvider).updateProfile(
                      user.id,
                      role: UserRole.selfLearner,
                    );
                ref.invalidate(studentMembershipProvider);
                ref.invalidate(isInGroupProvider);
                ref.invalidate(currentProfileProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to leave group: $e'),
                      backgroundColor: accentCoralDark,
                    ),
                  );
                }
                return;
              }
              if (context.mounted) {
                _showRoleChangePicker(
                    context, ref, profile.copyWith(role: UserRole.selfLearner));
              }
            },
            child: Text('Leave & Continue',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: Colors.red)),
          ),
        ],
      ),
    );
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
              await ref.read(profileServiceProvider).updateProfile(
                    user.id,
                    role: UserRole.selfLearner,
                  );
              ref.invalidate(studentMembershipProvider);
              ref.invalidate(isInGroupProvider);
              ref.invalidate(currentProfileProvider);
            },
            child: Text('Leave',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGroupInfoDialog(
      BuildContext context, WidgetRef ref, String groupId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder<String?>(
          future: ref.read(groupServiceProvider).getTeacherName(groupId),
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final teacherName = isLoading
                ? null
                : (snapshot.data ?? 'Unknown Teacher');
            return Dialog(
              backgroundColor: const Color(0xFF1E0E3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.black, width: 5),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: accentCoral.withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.school_rounded,
                          color: accentCoral, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Group',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: darkSurfaceBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_rounded,
                              color: darkTextSecondary, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Teacher',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: darkTextMuted,
                                ),
                              ),
                              if (isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      color: accentCoral, strokeWidth: 2),
                                )
                              else
                                Text(
                                  teacherName!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _showLeaveGroupDialog(context, ref);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: darkCardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              'Leave Group',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: accentCoralDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                  if (!ctx.mounted) return;
                  if (scanned != null && scanned.isNotEmpty) {
                    codeController.text = scanned;
                    setDialogState(() => errorText = null);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded,
                        color: accentCoral, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Scan QR Code',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: accentCoral,
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
                if (!ctx.mounted) return;
                if (group == null) {
                  setDialogState(() => errorText = 'Invalid invite code');
                  return;
                }
                try {
                  await groupService.joinGroup(user.id, group.id,
                      teacherId: group.teacherId);
                  ref.invalidate(studentMembershipProvider);
                  ref.invalidate(isInGroupProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  setDialogState(() => errorText = e.toString());
                }
              },
              child: Text('Join',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, color: accentCoral)),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentListSheet(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.read(teacherStudentsProvider);
    final students = studentsAsync.value ?? [];
    final groupAsync = ref.read(teacherGroupProvider);
    final groupId = groupAsync.value?.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E0E3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.black, width: 5),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Your Students',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${students.length}/20 students',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (students.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'No students yet',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkTextSecondary,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          bottom:
                              MediaQuery.of(ctx).padding.bottom + 16,
                        ),
                        itemCount: students.length,
                        itemBuilder: (context, i) {
                          final student = students[i];
                          return _buildStudentListItem(
                            ctx,
                            ref,
                            student,
                            groupId,
                            onRemoved: () {
                              setSheetState(() {
                                students.removeAt(i);
                              });
                              ref.invalidate(teacherStudentsProvider);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentListItem(
    BuildContext context,
    WidgetRef ref,
    StudentSummary student,
    String? groupId, {
    required VoidCallback onRemoved,
  }) {
    return Column(
      children: [
        const Divider(height: 1, color: darkDivider, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: darkSurfaceBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Text(
                    student.displayName.isNotEmpty
                        ? student.displayName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.displayName,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('lib/images/licensed/streak.svg',
                                width: 14, height: 14),
                            const SizedBox(width: 3),
                            Text(
                              '${student.currentStreak}d',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('lib/images/licensed/level.svg',
                                width: 14, height: 14),
                            const SizedBox(width: 3),
                            Text(
                              'Lv.${LevelUtils.levelFromXp(student.totalXp)}',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('lib/images/licensed/xp.svg',
                                width: 14, height: 14),
                            const SizedBox(width: 3),
                            Text(
                              '${student.totalXp} XP',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dlgCtx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E0E3D),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text(
                        'Remove Student',
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 20, color: Colors.white),
                      ),
                      content: Text(
                        'Are you sure you want to remove ${student.displayName} from your group?',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: darkTextSecondary,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dlgCtx, false),
                          child: Text('Cancel',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700,
                                  color: darkTextMuted)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dlgCtx, true),
                          child: Text('Remove',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && groupId != null) {
                    await ref
                        .read(groupServiceProvider)
                        .removeStudent(groupId, student.studentId);
                    if (!context.mounted) return;
                    ref.invalidate(unreadGroupNotificationsProvider);
                    onRemoved();
                  }
                },
                child: Text(
                  'Remove',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
    const goalOptions = [5, 10, 15, 20, 30, 45, 60, 90, 120];

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
                          .read(userSettingsProvider.notifier)
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
    final granted = await NotificationService.instance.requestPermission();
    if (granted) {
      ref
          .read(userSettingsProvider.notifier)
          .updateSetting('reminder_time', timeStr);
      await NotificationService.instance.scheduleDailyReminder(timeStr);
    }
  }

  Future<void> _clearReminder(WidgetRef ref) async {
    ref
        .read(userSettingsProvider.notifier)
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
                                  color: row.labelColor ?? Colors.white,
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
  final Color? labelColor;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
    this.labelColor,
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

