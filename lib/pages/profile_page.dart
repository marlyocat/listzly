import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:listzly/models/profile.dart';
import 'package:listzly/models/user_settings.dart';
import 'package:listzly/pages/intro_page.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/settings_provider.dart';
import 'package:listzly/providers/instrument_provider.dart';
import 'package:listzly/theme/colors.dart';

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
                  Text(
                    'Joined $joinDate',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: darkTextSecondary,
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
          trailing: _TrailingText(settings.reminderTime ?? 'Off'),
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

