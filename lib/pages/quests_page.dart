import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/models/assigned_quest.dart';
import 'package:listzly/models/quest.dart';
import 'package:listzly/models/user_role.dart';
import 'package:listzly/models/user_stats.dart';
import 'package:listzly/providers/assigned_quest_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/quest_provider.dart';
import 'package:listzly/providers/settings_provider.dart';
import 'package:listzly/providers/stats_provider.dart';
import 'package:listzly/services/quest_service.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/level_utils.dart';

/// Maps quest keys to their display icons.
const _questIconMap = <String, IconData>{
  'daily_xp_30': Icons.music_note_rounded,
  'daily_practice_20m': Icons.timer_rounded,
  'daily_sessions_2': Icons.piano_rounded,
  'weekly_xp_200': Icons.local_fire_department_rounded,
  'weekly_instruments_3': Icons.category_rounded,
  'weekly_streak_7': Icons.bolt_rounded,
};

/// Maps icon name strings (from assigned quests) to IconData.
const _iconNameMap = <String, IconData>{
  'timer_rounded': Icons.timer_rounded,
  'calendar_today_rounded': Icons.calendar_today_rounded,
  'star_rounded': Icons.star_rounded,
  'music_note_rounded': Icons.music_note_rounded,
  'category_rounded': Icons.category_rounded,
  'assignment_rounded': Icons.assignment_rounded,
};

class QuestsPage extends ConsumerStatefulWidget {
  const QuestsPage({super.key});

  @override
  ConsumerState<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends ConsumerState<QuestsPage>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimController;
  late Timer _countdownTimer;
  late Duration _timeRemaining;

  // Week day labels starting from Monday (matches backend week start).
  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // Today's index where Monday = 0, Sunday = 6.
  int get _todayIndex => DateTime.now().weekday - 1;

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

  /// Builds a [_Quest] from a [QuestProgress] and the matching definition list.
  ///
  /// [dailyGoalMinutes] is used to dynamically set the practice quest title.
  List<_Quest> _mapQuests(
    List<QuestProgress> progressList,
    List<QuestDefinition> definitions, {
    int? dailyGoalMinutes,
  }) {
    return progressList.map((qp) {
      // Find the matching definition for extra UI metadata.
      final def = definitions.firstWhere(
        (d) => d.key == qp.questKey,
        orElse: () => QuestDefinition(
          key: qp.questKey,
          type: qp.questType,
          title: qp.questKey,
          description: '',
          target: qp.target,
          rewardXp: 0,
        ),
      );

      // Use the user's daily goal for the practice quest title and reward.
      final isPracticeQuest =
          qp.questKey == 'daily_practice_20m' && dailyGoalMinutes != null;
      final title = isPracticeQuest
          ? 'Practice for $dailyGoalMinutes minutes'
          : def.title;
      final rewardXp = isPracticeQuest ? dailyGoalMinutes : def.rewardXp;

      return _Quest(
        icon: _questIconMap[qp.questKey] ?? Icons.star_rounded,
        title: title,
        description: def.description,
        currentProgress: qp.progress,
        targetProgress: qp.target,
        rewardAmount: rewardXp,
      );
    }).toList();
  }

  /// Builds a [_Quest] from an [AssignedQuest] definition and matching [QuestProgress].
  List<_Quest> _mapAssignedQuests(
    List<QuestProgress> progressList,
    List<AssignedQuest> definitions,
  ) {
    return progressList.map((qp) {
      final def = definitions.cast<AssignedQuest?>().firstWhere(
            (d) => d!.questKey == qp.questKey,
            orElse: () => null,
          );

      final desc = def?.description ?? '';
      final isRecurring = def?.isRecurring ?? false;

      return _Quest(
        icon: _iconNameMap[def?.iconName] ?? Icons.assignment_rounded,
        title: def?.title ?? qp.questKey,
        description: isRecurring
            ? (desc.isNotEmpty ? '$desc (Resets weekly)' : 'Resets weekly')
            : (desc.isNotEmpty ? '$desc (One time)' : 'One time'),
        currentProgress: qp.progress,
        targetProgress: qp.target,
        rewardAmount: def?.rewardXp ?? 0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dailyQuestsAsync = ref.watch(dailyQuestsProvider);
    final weekCompletionAsync = ref.watch(weekCompletionStatusProvider);
    final userStatsAsync = ref.watch(userStatsProvider);
    final settingsAsync = ref.watch(userSettingsNotifierProvider);
    final role =
        ref.watch(currentProfileProvider).valueOrNull?.role;

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
            SliverToBoxAdapter(
              child: weekCompletionAsync.when(
                data: (weekDays) => _buildWeeklyOverview(weekDays),
                loading: () => _buildLoadingPlaceholder(height: 90),
                error: (e, _) => _buildErrorPlaceholder(e),
              ),
            ),

            // Stats chips
            SliverToBoxAdapter(
              child: userStatsAsync.when(
                data: (stats) => _buildStatsChips(stats),
                loading: () => _buildLoadingPlaceholder(height: 60),
                error: (e, _) => _buildErrorPlaceholder(e),
              ),
            ),

            // Daily quests section
            SliverToBoxAdapter(
              child: dailyQuestsAsync.when(
                data: (quests) {
                  final goalMinutes = settingsAsync.valueOrNull?.dailyGoalMinutes;
                  return _buildQuestSection(
                    title: 'Daily Quests',
                    subtitle: _formatCountdown(_timeRemaining),
                    quests: _mapQuests(
                      quests,
                      dailyQuestDefinitions,
                      dailyGoalMinutes: goalMinutes,
                    ),
                  );
                },
                loading: () => _buildLoadingPlaceholder(height: 200),
                error: (e, _) => _buildErrorPlaceholder(e),
              ),
            ),

            // Assigned quests section (students only)
            if (role == UserRole.student)
              SliverToBoxAdapter(
                child: _buildAssignedQuestsSection(),
              ),

            // Bottom spacing for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedQuestsSection() {
    final progressAsync = ref.watch(assignedQuestProgressProvider);
    final defsAsync = ref.watch(assignedQuestDefinitionsProvider);

    return progressAsync.when(
      data: (progress) {
        if (progress.isEmpty) {
          return _buildEmptyAssignedSection();
        }
        final defs = defsAsync.valueOrNull ?? [];
        return _buildQuestSection(
          title: 'Assigned Quest',
          subtitle: 'From teacher',
          quests: _mapAssignedQuests(progress, defs),
        );
      },
      loading: () => _buildLoadingPlaceholder(height: 200),
      error: (e, _) => _buildErrorPlaceholder(e),
    );
  }

  Widget _buildEmptyAssignedSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        'No quests assigned yet',
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: darkTextSecondary,
        ),
      ),
    );
  }

  // ─── Loading / error placeholders ────────────────────────────────
  Widget _buildLoadingPlaceholder({required double height}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        height: height,
        child: const Center(
          child: CircularProgressIndicator(color: primaryLight),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(Object error) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Center(
        child: Text(
          'Something went wrong',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkTextSecondary,
          ),
        ),
      ),
    );
  }

  // ─── Weekly calendar overview ─────────────────────────────────────
  Widget _buildWeeklyOverview(List<bool> weekDays) {
    final todayIndex = _todayIndex;

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
            final isToday = i == todayIndex;
            final completed = i < weekDays.length && weekDays[i];
            final isPast = i < todayIndex;

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
  Widget _buildStatsChips(UserStats stats) {
    final level = LevelUtils.levelFromXp(stats.totalXp);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _buildChip(
            '${stats.currentStreak} ${stats.currentStreak == 1 ? 'Day' : 'Days'}',
            'Streak',
            Colors.white,
          ),
          const SizedBox(width: 10),
          _buildChip('$level', 'Level', Colors.white),
          const SizedBox(width: 10),
          _buildChip('${stats.totalXp}', 'Total XP', Colors.white),
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
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: darkTextSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
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
