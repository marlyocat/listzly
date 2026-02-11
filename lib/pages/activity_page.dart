import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with TickerProviderStateMixin {
  late AnimationController _animController;

  // Mock data
  final int _currentStreak = 3;
  final int _totalXP = 846;
  final int _totalMinutes = 285;
  final int _totalSessions = 19;

  // Days of week streak (true = practiced)
  final List<bool> _weekDays = [true, true, true, false, false, false, false];
  final List<String> _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  final List<_SessionEntry> _recentSessions = [
    _SessionEntry(instrument: 'Piano', duration: 25, xp: 30, icon: Icons.piano_rounded, color: primaryColor, timeAgo: 'Today'),
    _SessionEntry(instrument: 'Guitar', duration: 15, xp: 18, icon: Icons.music_note_rounded, color: primaryLight, timeAgo: 'Today'),
    _SessionEntry(instrument: 'Piano', duration: 30, xp: 35, icon: Icons.piano_rounded, color: primaryColor, timeAgo: 'Yesterday'),
    _SessionEntry(instrument: 'Violin', duration: 20, xp: 22, icon: Icons.music_note_outlined, color: accentCoral, timeAgo: 'Yesterday'),
    _SessionEntry(instrument: 'Drums', duration: 10, xp: 12, icon: Icons.surround_sound_rounded, color: primaryDark, timeAgo: '2 days ago'),
    _SessionEntry(instrument: 'Piano', duration: 45, xp: 50, icon: Icons.piano_rounded, color: primaryColor, timeAgo: '3 days ago'),
  ];

  final List<_Achievement> _achievements = [
    _Achievement(icon: Icons.local_fire_department_rounded, title: 'Hot Streak', description: '3 days in a row', color: accentCoral, earned: true),
    _Achievement(icon: Icons.music_note_rounded, title: 'First Note', description: 'Complete first session', color: primaryColor, earned: true),
    _Achievement(icon: Icons.timer_rounded, title: 'Marathon', description: 'Practice 60 min in a day', color: primaryLight, earned: false),
    _Achievement(icon: Icons.star_rounded, title: 'Virtuoso', description: 'Earn 1000 XP total', color: accentCoral, earned: false),
    _Achievement(icon: Icons.category_rounded, title: 'Multi-talent', description: 'Play all 4 instruments', color: primaryLight, earned: false),
    _Achievement(icon: Icons.bolt_rounded, title: 'Unstoppable', description: '7 day streak', color: primaryDark, earned: false),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: purpleGradientColors,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Activity',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Streak card
              SliverToBoxAdapter(child: _buildStreakCard()),

              // Stats row
              SliverToBoxAdapter(child: _buildStatsRow()),

              // Achievements section
              SliverToBoxAdapter(child: _buildAchievementsSection()),

              // Recent sessions
              SliverToBoxAdapter(child: _buildRecentSessionsSection()),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accentCoral, accentCoralDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentCoral.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Flame icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_currentStreak day streak!',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Keep it going!',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Weekly calendar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final practiced = _weekDays[index];
                  return Column(
                    children: [
                      Text(
                        _dayLabels[index],
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          final delay = index * 0.1;
                          final progress = ((_animController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
                          return Transform.scale(
                            scale: practiced ? progress : 1.0,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: practiced
                                ? Colors.white
                                : Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: practiced
                              ? Icon(Icons.check_rounded,
                                  color: accentCoralDark, size: 20)
                              : null,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.bolt_rounded,
              value: '$_totalXP',
              label: 'Total XP',
              color: accentCoral,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.timer_rounded,
              value: '${_totalMinutes}m',
              label: 'Practice',
              color: primaryLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle_rounded,
              value: '$_totalSessions',
              label: 'Sessions',
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: accentCoral, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Achievements',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3C3C3C),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_achievements.where((a) => a.earned).length}/${_achievements.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFAFAFAF),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                itemCount: _achievements.length,
                itemBuilder: (context, index) {
                  final achievement = _achievements[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 88,
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: achievement.earned
                                  ? achievement.color.withOpacity(0.15)
                                  : const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(16),
                              border: achievement.earned
                                  ? Border.all(color: achievement.color.withOpacity(0.4), width: 2)
                                  : null,
                            ),
                            child: Icon(
                              achievement.icon,
                              color: achievement.earned
                                  ? achievement.color
                                  : const Color(0xFFD0D0D0),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            achievement.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: achievement.earned
                                  ? const Color(0xFF3C3C3C)
                                  : const Color(0xFFAFAFAF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsSection() {
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: primaryLight, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Sessions',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3C3C3C),
                    ),
                  ),
                ],
              ),
            ),
            // Session list
            ...List.generate(_recentSessions.length, (index) {
              final session = _recentSessions[index];
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1, indent: 72, endIndent: 16, color: Color(0xFFF0F0F0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Instrument icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: session.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(session.icon, color: session.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.instrument,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF3C3C3C),
                                ),
                              ),
                              Text(
                                '${session.duration} min  ·  ${session.timeAgo}',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFAFAFAF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // XP earned
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentCoralLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: accentCoralDark),
                              const SizedBox(width: 2),
                              Text(
                                '+${session.xp}',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: accentCoralDark,
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
}

class _SessionEntry {
  final String instrument;
  final int duration;
  final int xp;
  final IconData icon;
  final Color color;
  final String timeAgo;

  const _SessionEntry({
    required this.instrument,
    required this.duration,
    required this.xp,
    required this.icon,
    required this.color,
    required this.timeAgo,
  });
}

class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool earned;

  const _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.earned,
  });
}
