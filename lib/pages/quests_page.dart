import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimController;
  late Timer _countdownTimer;
  late Duration _timeRemaining;

  // Week day labels and completion status
  final List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<bool> _weekDays = [true, true, true, false, false, false, false];
  final int _todayIndex = 3; // Wednesday

  // Mock quest data
  final List<_Quest> _dailyQuests = [
    _Quest(
      icon: Icons.music_note_rounded,
      title: 'Earn 30 XP',
      description: 'Practice any instrument',
      currentProgress: 18,
      targetProgress: 30,
      rewardAmount: 10,
    ),
    _Quest(
      icon: Icons.timer_rounded,
      title: 'Practice for 20 minutes',
      description: 'Total practice time today',
      currentProgress: 12,
      targetProgress: 20,
      rewardAmount: 15,
    ),
    _Quest(
      icon: Icons.piano_rounded,
      title: 'Complete 2 sessions',
      description: 'Finish full practice sessions',
      currentProgress: 1,
      targetProgress: 2,
      rewardAmount: 10,
    ),
  ];

  final List<_Quest> _weeklyQuests = [
    _Quest(
      icon: Icons.local_fire_department_rounded,
      title: 'Earn 200 XP',
      description: 'Keep up the momentum!',
      currentProgress: 85,
      targetProgress: 200,
      rewardAmount: 50,
    ),
    _Quest(
      icon: Icons.category_rounded,
      title: 'Try 3 instruments',
      description: 'Variety is the spice of music',
      currentProgress: 1,
      targetProgress: 3,
      rewardAmount: 30,
    ),
    _Quest(
      icon: Icons.bolt_rounded,
      title: '7 day streak',
      description: 'Practice every day this week',
      currentProgress: 3,
      targetProgress: 7,
      rewardAmount: 100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _timeRemaining = midnight.difference(now);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeRemaining.inSeconds > 0) {
        setState(() {
          _timeRemaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _progressAnimController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m left';
  }

  @override
  Widget build(BuildContext context) {
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
                    'Quests',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Weekly overview card
            SliverToBoxAdapter(child: _buildWeeklyOverview()),

            // Stats chips
            SliverToBoxAdapter(child: _buildStatsChips()),

            // Daily quests section
            SliverToBoxAdapter(
              child: _buildQuestSection(
                title: 'Daily Quests',
                subtitle: _formatCountdown(_timeRemaining),
                quests: _dailyQuests,
              ),
            ),

            // Weekly challenges section
            SliverToBoxAdapter(
              child: _buildQuestSection(
                title: 'Weekly Challenges',
                subtitle: 'Resets Monday',
                quests: _weeklyQuests,
              ),
            ),

            // Bottom spacing for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ─── Weekly calendar overview ─────────────────────────────────────
  Widget _buildWeeklyOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Material(
        elevation: 12,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: heroCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 5),
          ),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final isToday = i == _todayIndex;
            final completed = _weekDays[i];
            final isPast = i < _todayIndex;

            return Column(
              children: [
                Text(
                  _dayLabels[i],
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: completed
                        ? primaryColor
                        : isToday
                            ? primaryColor.withValues(alpha: 0.3)
                            : darkSurfaceBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : isPast
                          ? const Icon(
                              Icons.close_rounded,
                              color: darkTextSecondary,
                              size: 16,
                            )
                          : null,
                ),
              ],
            );
          }),
        ),
      ),
      ),
    );
  }

  // ─── Stats chips row ──────────────────────────────────────────────
  Widget _buildStatsChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _buildChip('3 Days', 'Streak', Colors.white),
          const SizedBox(width: 10),
          _buildChip('4h 45m', 'This Week', Colors.white),
          const SizedBox(width: 10),
          _buildChip('846', 'Total XP', Colors.white),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label, Color color) {
    return Expanded(
      child: Material(
        elevation: 12,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: darkCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 5),
          ),
          child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // ─── Quest section (daily or weekly) ──────────────────────────────
  Widget _buildQuestSection({
    required String title,
    required String subtitle,
    required List<_Quest> quests,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Material(
        elevation: 12,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: darkCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 5),
          ),
          child: Column(
            children: [
              // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Quest items
            ...quests.asMap().entries.map((entry) {
              final index = entry.key;
              final quest = entry.value;
              return Column(
                children: [
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: darkDivider,
                  ),
                  _buildQuestTile(quest),
                  if (index == quests.length - 1) const SizedBox(height: 6),
                ],
              );
            }),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildQuestTile(_Quest quest) {
    final progress = quest.currentProgress / quest.targetProgress;
    final isComplete = quest.currentProgress >= quest.targetProgress;

    return AnimatedBuilder(
      animation: _progressAnimController,
      builder: (context, child) {
        final animatedProgress = progress * _progressAnimController.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isComplete
                      ? primaryColor.withValues(alpha: 0.25)
                      : primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Icon(
                  isComplete ? Icons.check_rounded : quest.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Quest info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quest.title,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isComplete
                                  ? darkTextSecondary
                                  : Colors.white,
                              decoration: isComplete
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        // Reward
                        Text(
                          '+${quest.rewardAmount} XP',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isComplete
                                ? darkTextMuted
                                : accentCoral,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quest.description,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar + counter
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              height: 8,
                              child: Stack(
                                children: [
                                  Container(color: darkProgressBg),
                                  FractionallySizedBox(
                                    widthFactor:
                                        animatedProgress.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isComplete
                                            ? primaryColor
                                            : primaryLight,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${quest.currentProgress}/${quest.targetProgress}',
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Quest {
  final IconData icon;
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final int rewardAmount;

  const _Quest({
    required this.icon,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    required this.rewardAmount,
  });
}
