import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> with TickerProviderStateMixin {
  late AnimationController _progressAnimController;
  late Timer _countdownTimer;
  late Duration _timeRemaining;

  // Mock quest data
  final List<_Quest> _dailyQuests = [
    _Quest(
      icon: Icons.music_note_rounded,
      iconColor: primaryColor,
      title: 'Earn 30 XP',
      description: 'Practice any instrument',
      currentProgress: 18,
      targetProgress: 30,
      rewardAmount: 10,
      rewardType: _RewardType.gems,
    ),
    _Quest(
      icon: Icons.timer_rounded,
      iconColor: primaryLight,
      title: 'Practice for 20 minutes',
      description: 'Total practice time today',
      currentProgress: 12,
      targetProgress: 20,
      rewardAmount: 15,
      rewardType: _RewardType.gems,
    ),
    _Quest(
      icon: Icons.piano_rounded,
      iconColor: primaryLight,
      title: 'Complete 2 sessions',
      description: 'Finish full practice sessions',
      currentProgress: 1,
      targetProgress: 2,
      rewardAmount: 10,
      rewardType: _RewardType.gems,
    ),
  ];

  final List<_Quest> _weeklyQuests = [
    _Quest(
      icon: Icons.local_fire_department_rounded,
      iconColor: accentCoral,
      title: 'Earn 200 XP',
      description: 'Keep up the momentum!',
      currentProgress: 85,
      targetProgress: 200,
      rewardAmount: 50,
      rewardType: _RewardType.gems,
    ),
    _Quest(
      icon: Icons.category_rounded,
      iconColor: primaryDark,
      title: 'Try 3 instruments',
      description: 'Variety is the spice of music',
      currentProgress: 1,
      targetProgress: 3,
      rewardAmount: 30,
      rewardType: _RewardType.gems,
    ),
    _Quest(
      icon: Icons.bolt_rounded,
      iconColor: accentCoral,
      title: '7 day streak',
      description: 'Practice every day this week',
      currentProgress: 3,
      targetProgress: 7,
      rewardAmount: 100,
      rewardType: _RewardType.gems,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Calculate time until midnight
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

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
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
                  child: Row(
                    children: [
                      Text(
                        'Quests',
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    const Spacer(),
                    // Streak badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded, color: accentCoral, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '3',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
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
            ),

            // Daily Quests Section
            SliverToBoxAdapter(
              child: _buildSectionCard(
                headerColor: primaryColor,
                headerIcon: Icons.wb_sunny_rounded,
                headerTitle: 'Daily Quests',
                headerSubtitle: '${_formatDuration(_timeRemaining)} left',
                quests: _dailyQuests,
              ),
            ),

            // Weekly Quests Section
            SliverToBoxAdapter(
              child: _buildSectionCard(
                headerColor: primaryLight,
                headerIcon: Icons.calendar_today_rounded,
                headerTitle: 'Weekly Challenges',
                headerSubtitle: 'Resets Monday',
                quests: _weeklyQuests,
              ),
            ),

            // Friend Quest
            SliverToBoxAdapter(
              child: _buildFriendQuestCard(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Color headerColor,
    required IconData headerIcon,
    required String headerTitle,
    required String headerSubtitle,
    required List<_Quest> quests,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Section header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(headerIcon, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    headerTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      headerSubtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Quest items
            ...quests.asMap().entries.map((entry) {
              final index = entry.key;
              final quest = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0)),
                  _buildQuestTile(quest),
                ],
              );
            }),
          ],
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
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isComplete
                      ? accentCoral.withOpacity(0.15)
                      : quest.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isComplete ? Icons.check_rounded : quest.icon,
                  color: isComplete ? accentCoral : quest.iconColor,
                  size: 24,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isComplete
                                  ? const Color(0xFF999999)
                                  : const Color(0xFF3C3C3C),
                              decoration: isComplete ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        // Reward badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isComplete
                                ? const Color(0xFFE5E5E5)
                                : accentCoralLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                quest.rewardType == _RewardType.gems
                                    ? Icons.diamond_rounded
                                    : Icons.bolt_rounded,
                                size: 14,
                                color: isComplete
                                    ? const Color(0xFF999999)
                                    : accentCoralDark,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '+${quest.rewardAmount}',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isComplete
                                      ? const Color(0xFF999999)
                                      : accentCoralDark,
                                ),
                              ),
                            ],
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
                        color: const Color(0xFFAFAFAF),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              height: 12,
                              child: Stack(
                                children: [
                                  // Background
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E5E5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  // Progress fill
                                  FractionallySizedBox(
                                    widthFactor: animatedProgress.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isComplete
                                              ? [accentCoral, accentCoralDark]
                                              : [quest.iconColor.withOpacity(0.8), quest.iconColor],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (isComplete ? accentCoral : quest.iconColor)
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      // Shine effect
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          height: 4,
                                          margin: const EdgeInsets.only(top: 2, left: 4, right: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFAFAFAF),
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

  Widget _buildFriendQuestCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Friend quest icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Friend Quest',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invite a friend to practice together and earn bonus rewards!',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'INVITE',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _RewardType { gems }

class _Quest {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final int rewardAmount;
  final _RewardType rewardType;

  const _Quest({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    required this.rewardAmount,
    required this.rewardType,
  });
}
