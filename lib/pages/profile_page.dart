import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkest,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: profileGradientColors,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, accentCoral],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Settings',
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
            SliverToBoxAdapter(child: _buildProfileCard()),

            // Stats row
            SliverToBoxAdapter(child: _buildStatsRow()),

            // Display section
            SliverToBoxAdapter(
              child: _buildSettingsSection(
                title: 'Display',
                items: [
                  _SettingsRow(
                    icon: Icons.palette_outlined,
                    label: 'Theme',
                    trailing: _TrailingText('System'),
                  ),
                  _SettingsRow(
                    icon: Icons.text_fields_rounded,
                    label: 'Date & Time Language',
                    trailing: _TrailingText('English'),
                  ),
                  _SettingsRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'First Day of Week',
                    trailing: _TrailingText('Monday'),
                  ),
                ],
              ),
            ),

            // Practice section
            SliverToBoxAdapter(
              child: _buildSettingsSection(
                title: 'Practice',
                items: [
                  _SettingsRow(
                    icon: Icons.timer_outlined,
                    label: 'Daily Goal',
                    trailing: _TrailingText('15 min'),
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_outlined,
                    label: 'Reminders',
                    trailing: _TrailingText('7:00 PM'),
                  ),
                  _SettingsRow(
                    icon: Icons.volume_up_outlined,
                    label: 'Sound Effects',
                    trailing: _TrailingToggle(true),
                  ),
                  _SettingsRow(
                    icon: Icons.bar_chart_rounded,
                    label: 'Show Progress Bar',
                    trailing: _TrailingToggle(true),
                  ),
                ],
              ),
            ),

            // Instruments section
            SliverToBoxAdapter(child: _buildInstrumentsSection()),

            // About section
            SliverToBoxAdapter(
              child: _buildSettingsSection(
                title: 'About',
                items: [
                  _SettingsRow(
                    icon: Icons.new_releases_outlined,
                    label: "What's New",
                    trailing: _TrailingChevron(),
                  ),
                  _SettingsRow(
                    icon: Icons.shield_outlined,
                    label: 'Data Privacy',
                    trailing: _TrailingChevron(),
                  ),
                  _SettingsRow(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    trailing: _TrailingChevron(),
                  ),
                ],
              ),
            ),

            // Bottom spacing for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      ),
    );
  }

  // ─── Profile card ─────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: heroCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: heroCardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
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
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: accentCoral,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            // Name + join date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Music Man',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Joined February 2026',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Edit button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: darkSurfaceBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: darkTextMuted,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Stats row ────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _buildStatChip('5 days', 'Days Active', accentCoral),
          const SizedBox(width: 10),
          _buildStatChip('4h 45m', 'Time Spent', accentCoralLight),
          const SizedBox(width: 10),
          _buildStatChip('3 days', 'Longest Streak', Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: darkCardBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
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
              border: Border.all(color: darkCardBorder),
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
                    Padding(
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
  Widget _buildInstrumentsSection() {
    final instruments = [
      _InstrumentStat(
          name: 'Piano',
          icon: Icons.piano_rounded,
          color: primaryColor,
          sessions: 12,
          minutes: 180),
      _InstrumentStat(
          name: 'Guitar',
          icon: Icons.music_note_rounded,
          color: const Color(0xFFD4A056),
          sessions: 5,
          minutes: 65),
      _InstrumentStat(
          name: 'Violin',
          icon: Icons.music_note_outlined,
          color: accentCoral,
          sessions: 1,
          minutes: 20),
      _InstrumentStat(
          name: 'Drums',
          icon: Icons.surround_sound_rounded,
          color: const Color(0xFF5B9A6B),
          sessions: 1,
          minutes: 20),
    ];

    final totalMinutes =
        instruments.fold<int>(0, (sum, i) => sum + i.minutes);

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
              border: Border.all(color: darkCardBorder),
            ),
            child: Column(
              children: instruments.asMap().entries.map((entry) {
                final i = entry.key;
                final inst = entry.value;
                final fraction =
                    totalMinutes > 0 ? inst.minutes / totalMinutes : 0.0;

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
                            ),
                            child: Icon(inst.icon,
                                color: inst.color, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inst.name,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: SizedBox(
                                    height: 6,
                                    child: Stack(
                                      children: [
                                        Container(
                                            color: darkProgressBg),
                                        FractionallySizedBox(
                                          widthFactor:
                                              fraction.clamp(0.0, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: inst.color,
                                              borderRadius:
                                                  BorderRadius.circular(3),
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${inst.minutes} min',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${inst.sessions} sessions',
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
}

// ─── Settings row model + trailing widgets ──────────────────────────
class _SettingsRow {
  final IconData icon;
  final String label;
  final _Trailing trailing;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
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

class _TrailingToggle extends _Trailing {
  final bool value;
  const _TrailingToggle(this.value);

  @override
  Widget build() {
    return SizedBox(
      height: 28,
      width: 48,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: (_) {},
          activeThumbColor: Colors.white,
          activeTrackColor: primaryColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: darkTextMuted,
        ),
      ),
    );
  }
}

class _TrailingChevron extends _Trailing {
  const _TrailingChevron();

  @override
  Widget build() {
    return const Icon(
      Icons.chevron_right,
      color: darkTextMuted,
      size: 20,
    );
  }
}

class _InstrumentStat {
  final String name;
  final IconData icon;
  final Color color;
  final int sessions;
  final int minutes;

  const _InstrumentStat({
    required this.name,
    required this.icon,
    required this.color,
    required this.sessions,
    required this.minutes,
  });
}
