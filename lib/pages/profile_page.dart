import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3C3C3C),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                      ),
                      child: const Icon(Icons.settings_rounded, color: Color(0xFF3C3C3C), size: 22),
                    ),
                  ],
                ),
              ),
            ),

            // Profile card
            SliverToBoxAdapter(child: _buildProfileCard()),

            // Stats grid
            SliverToBoxAdapter(child: _buildStatsGrid()),

            // Instruments section
            SliverToBoxAdapter(child: _buildInstrumentsSection()),

            // Preferences section
            SliverToBoxAdapter(child: _buildPreferencesSection()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Music Man',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3C3C3C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Joined February 2026',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFAFAFAF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFF9600)),
                          const SizedBox(width: 4),
                          Text(
                            'Level 5  ·  846 XP',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF9600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Edit icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded, color: Color(0xFFAFAFAF), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildMiniStat(
                  icon: Icons.local_fire_department_rounded,
                  value: '3',
                  label: 'Day Streak',
                  color: const Color(0xFFFF9600),
                ),
                const SizedBox(height: 10),
                _buildMiniStat(
                  icon: Icons.bolt_rounded,
                  value: '846',
                  label: 'Total XP',
                  color: const Color(0xFFFFC800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                _buildMiniStat(
                  icon: Icons.diamond_rounded,
                  value: '120',
                  label: 'Gems',
                  color: const Color(0xFF1CB0F6),
                ),
                const SizedBox(height: 10),
                _buildMiniStat(
                  icon: Icons.emoji_events_rounded,
                  value: '2',
                  label: 'Achievements',
                  color: const Color(0xFFCE82FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3C3C3C),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFAFAFAF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentsSection() {
    final instruments = [
      _InstrumentStat(name: 'Piano', icon: Icons.piano_rounded, color: const Color(0xFF58CC02), sessions: 12, minutes: 180),
      _InstrumentStat(name: 'Guitar', icon: Icons.music_note_rounded, color: const Color(0xFFCE82FF), sessions: 5, minutes: 65),
      _InstrumentStat(name: 'Violin', icon: Icons.music_note_outlined, color: const Color(0xFFFF9600), sessions: 1, minutes: 20),
      _InstrumentStat(name: 'Drums', icon: Icons.surround_sound_rounded, color: const Color(0xFFFF4B4B), sessions: 1, minutes: 20),
    ];

    final totalMinutes = instruments.fold<int>(0, (sum, i) => sum + i.minutes);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const Icon(Icons.queue_music_rounded, color: Color(0xFF7C3AED), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'My Instruments',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3C3C3C),
                    ),
                  ),
                ],
              ),
            ),
            ...instruments.asMap().entries.map((entry) {
              final index = entry.key;
              final inst = entry.value;
              final fraction = totalMinutes > 0 ? inst.minutes / totalMinutes : 0.0;

              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1, indent: 72, endIndent: 16, color: Color(0xFFF0F0F0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: inst.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(inst.icon, color: inst.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    inst.name,
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF3C3C3C),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${inst.minutes} min',
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFAFAFAF),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  height: 8,
                                  child: Stack(
                                    children: [
                                      Container(color: const Color(0xFFE5E5E5)),
                                      FractionallySizedBox(
                                        widthFactor: fraction.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: inst.color,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${inst.sessions} sessions',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFAFAFAF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final items = [
      _PrefItem(icon: Icons.notifications_rounded, title: 'Reminders', subtitle: 'Daily at 7:00 PM', color: const Color(0xFF58CC02)),
      _PrefItem(icon: Icons.timer_rounded, title: 'Daily Goal', subtitle: '15 minutes per day', color: const Color(0xFFCE82FF)),
      _PrefItem(icon: Icons.dark_mode_rounded, title: 'Appearance', subtitle: 'Light mode', color: const Color(0xFF1CB0F6)),
      _PrefItem(icon: Icons.volume_up_rounded, title: 'Sound Effects', subtitle: 'On', color: const Color(0xFFFF9600)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, color: Color(0xFF3C3C3C), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Preferences',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3C3C3C),
                    ),
                  ),
                ],
              ),
            ),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1, indent: 72, endIndent: 16, color: Color(0xFFF0F0F0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF3C3C3C),
                                ),
                              ),
                              Text(
                                item.subtitle,
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFAFAFAF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFD0D0D0), size: 24),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
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

class _PrefItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PrefItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
