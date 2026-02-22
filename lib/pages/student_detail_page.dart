import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/models/practice_session.dart';
import 'package:listzly/models/practice_recording.dart';
import 'package:listzly/providers/student_data_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/providers/recording_provider.dart';
import 'package:listzly/components/recording_list_tile.dart';
import 'package:listzly/components/recording_player.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/level_utils.dart';

class StudentDetailPage extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;
  final String? groupId;

  const StudentDetailPage({
    super.key,
    required this.studentId,
    required this.studentName,
    this.groupId,
  });

  @override
  ConsumerState<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends ConsumerState<StudentDetailPage>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  late final AnimationController _barAnimController;
  late final Animation<double> _barAnim;

  static const _dayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _instrumentIcons = {
    'Piano': Icons.piano,
    'Guitar': Icons.music_note,
    'Violin': Icons.library_music,
    'Drums': Icons.surround_sound,
  };

  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();
    _computeDateRange();
    _barAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnim = CurvedAnimation(
      parent: _barAnimController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _barAnimController.forward();
    });
  }

  @override
  void dispose() {
    _barAnimController.dispose();
    super.dispose();
  }

  void _computeDateRange() {
    final now = DateTime.now();
    switch (_selectedTab) {
      case 0:
        final weekday = now.weekday % 7;
        _rangeStart = DateTime(now.year, now.month, now.day - weekday);
        _rangeEnd = _rangeStart.add(const Duration(days: 6));
        break;
      case 1:
        _rangeStart = DateTime(now.year, now.month);
        _rangeEnd = DateTime(now.year, now.month + 1)
            .subtract(const Duration(days: 1));
        break;
      case 2:
        _rangeStart = DateTime(now.year);
        _rangeEnd = DateTime(now.year, 12, 31);
        break;
    }
  }

  void _shiftRangeBack() {
    setState(() {
      switch (_selectedTab) {
        case 0:
          _rangeStart = _rangeStart.subtract(const Duration(days: 7));
          _rangeEnd = _rangeEnd.subtract(const Duration(days: 7));
          break;
        case 1:
          _rangeStart = DateTime(_rangeStart.year, _rangeStart.month - 1);
          _rangeEnd = DateTime(_rangeStart.year, _rangeStart.month + 1)
              .subtract(const Duration(days: 1));
          break;
        case 2:
          _rangeStart = DateTime(_rangeStart.year - 1);
          _rangeEnd = DateTime(_rangeStart.year, 12, 31);
          break;
      }
      _restartBarAnimation();
    });
  }

  void _shiftRangeForward() {
    setState(() {
      switch (_selectedTab) {
        case 0:
          _rangeStart = _rangeStart.add(const Duration(days: 7));
          _rangeEnd = _rangeEnd.add(const Duration(days: 7));
          break;
        case 1:
          _rangeStart = DateTime(_rangeStart.year, _rangeStart.month + 1);
          _rangeEnd = DateTime(_rangeStart.year, _rangeStart.month + 1)
              .subtract(const Duration(days: 1));
          break;
        case 2:
          _rangeStart = DateTime(_rangeStart.year + 1);
          _rangeEnd = DateTime(_rangeStart.year, 12, 31);
          break;
      }
      _restartBarAnimation();
    });
  }

  void _restartBarAnimation() {
    _barAnimController.reset();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _barAnimController.forward();
    });
  }

  String _formatDateRange() {
    switch (_selectedTab) {
      case 0:
        if (_rangeStart.month == _rangeEnd.month) {
          return '${_monthNames[_rangeStart.month - 1]} ${_rangeStart.day} \u2013 ${_rangeEnd.day}, ${_rangeEnd.year}';
        }
        return '${_monthNames[_rangeStart.month - 1]} ${_rangeStart.day} \u2013 ${_monthNames[_rangeEnd.month - 1]} ${_rangeEnd.day}, ${_rangeEnd.year}';
      case 1:
        return '${_monthNames[_rangeStart.month - 1]} ${_rangeStart.year}';
      case 2:
        return '${_rangeStart.year}';
      default:
        return '';
    }
  }

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    if (minutes > 0 && seconds > 0) return '${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m';
    return '${seconds}s';
  }

  static String _formatSessionDuration(int durationSeconds) {
    return _formatDuration(Duration(seconds: durationSeconds));
  }

  static String _formatSessionDate(DateTime dt) {
    return '${dt.day} ${_monthNames[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(
      studentSessionsProvider(
          studentId: widget.studentId, start: _rangeStart, end: _rangeEnd),
    );
    final barDataAsync = ref.watch(
      studentWeeklyBarDataProvider(
          studentId: widget.studentId, weekStart: _rangeStart),
    );
    final statsAsync = ref.watch(
      studentSummaryStatsProvider(
          studentId: widget.studentId, start: _rangeStart, end: _rangeEnd),
    );
    final studentStatsAsync = ref.watch(
      studentStatsProvider(studentId: widget.studentId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with back button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          widget.studentName,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Streak + XP chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: studentStatsAsync.when(
                  data: (stats) => Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        Icons.local_fire_department_rounded,
                        '${stats.currentStreak} day streak',
                        accentCoral,
                        imagePath: 'lib/images/streak.png',
                      ),
                      _buildChip(
                        Icons.shield_rounded,
                        'Lv. ${LevelUtils.levelFromXp(stats.totalXp)}',
                        primaryColor,
                        imagePath: 'lib/images/level.png',
                      ),
                      _buildChip(
                        Icons.star_rounded,
                        '${stats.totalXp} XP',
                        primaryLight,
                        imagePath: 'lib/images/xp.png',
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(height: 36),
                  error: (_, __) => const SizedBox(height: 36),
                ),
              ),
            ),

            // Segmented tabs
            SliverToBoxAdapter(child: _buildSegmentedTabs()),

            // Date stats
            SliverToBoxAdapter(child: _buildDateStats(statsAsync)),

            // Summary stats
            SliverToBoxAdapter(child: _buildSummaryStats(statsAsync)),

            // Bar chart
            SliverToBoxAdapter(child: _buildBarChart(barDataAsync)),

            // Sessions list
            SliverToBoxAdapter(child: _buildSessionList(sessionsAsync)),

            // Student recordings (teacher view)
            SliverToBoxAdapter(child: _buildRecordingsList()),

            // Remove student button
            if (widget.groupId != null)
              SliverToBoxAdapter(child: _buildRemoveButton()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, Color color,
      {String? imagePath}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imagePath != null)
            Image.asset(imagePath, width: 16, height: 16)
          else
            Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    const labels = ['Week', 'Month', 'Year'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = (constraints.maxWidth - 6) / 3;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: 3 + (_selectedTab * tabWidth),
                  top: 3,
                  bottom: 3,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentCoral, accentCoralDark],
                      ),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: accentCoral.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: List.generate(3, (i) {
                    final selected = _selectedTab == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = i;
                            _computeDateRange();
                            _restartBarAnimation();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected ? Colors.white : darkTextMuted,
                            ),
                            child: Text(labels[i]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateStats(
    AsyncValue<({Duration totalTime, int sessionCount})> statsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateRange(),
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                statsAsync.when(
                  data: (stats) => Text(
                    '${stats.sessionCount} Session${stats.sessionCount == 1 ? '' : 's'}',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accentCoral,
                    ),
                  ),
                  loading: () => SizedBox(
                    height: 20,
                    width: 80,
                    child: LinearProgressIndicator(
                      backgroundColor: darkCardBg,
                      color: accentCoral.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  error: (_, __) => Text(
                    '\u2014',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: accentCoral,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildCircleIconButton(Icons.chevron_left, onTap: _shiftRangeBack),
              const SizedBox(width: 8),
              _buildCircleIconButton(Icons.chevron_right,
                  onTap: _shiftRangeForward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: darkSurfaceBg,
          shape: BoxShape.circle,
          border: Border.all(color: darkCardBorder),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildSummaryStats(
    AsyncValue<({Duration totalTime, int sessionCount})> statsAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: statsAsync.when(
        data: (stats) => Row(
          children: [
            _buildStatCard(
              icon: Icons.access_time_rounded,
              value: _formatDuration(stats.totalTime),
              label: 'Total Time',
              color: accentCoral,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              icon: Icons.music_note_rounded,
              value: '${stats.sessionCount}',
              label: 'Sessions',
              color: primaryLight,
            ),
          ],
        ),
        loading: () => Row(
          children: [
            _buildStatCard(
                icon: Icons.access_time_rounded,
                value: '\u2014',
                label: 'Total Time',
                color: accentCoral),
            const SizedBox(width: 10),
            _buildStatCard(
                icon: Icons.music_note_rounded,
                value: '\u2014',
                label: 'Sessions',
                color: primaryLight),
          ],
        ),
        error: (_, __) => Row(
          children: [
            _buildStatCard(
                icon: Icons.access_time_rounded,
                value: '\u2014',
                label: 'Total Time',
                color: accentCoral),
            const SizedBox(width: 10),
            _buildStatCard(
                icon: Icons.music_note_rounded,
                value: '\u2014',
                label: 'Sessions',
                color: primaryLight),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Material(
        elevation: 12,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: darkCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: darkSurfaceBg,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Icon(icon, color: Colors.white, size: 19),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: darkTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(AsyncValue<Map<DateTime, int>> barDataAsync) {
    return barDataAsync.when(
      data: (barMap) => _buildBarChartContent(_barMapToList(barMap)),
      loading: () => _buildBarChartContent(List.filled(7, 0.0)),
      error: (_, __) => _buildBarChartContent(List.filled(7, 0.0)),
    );
  }

  List<double> _barMapToList(Map<DateTime, int> barMap) {
    final result = List<double>.filled(7, 0.0);
    for (var i = 0; i < 7; i++) {
      final day = _rangeStart.add(Duration(days: i));
      final key = DateTime(day.year, day.month, day.day);
      result[i] = (barMap[key] ?? 0).toDouble();
    }
    return result;
  }

  Widget _buildBarChartContent(List<double> weeklyBarData) {
    final dataMax =
        weeklyBarData.reduce((a, b) => a > b ? a : b).ceilToDouble();
    final rawMax = dataMax < 30 ? 30.0 : dataMax;
    final interval = rawMax <= 15
        ? 5.0
        : rawMax <= 30
            ? 10.0
            : rawMax <= 60
                ? 15.0
                : 30.0;
    final yMax = (rawMax / interval).ceil() * interval;
    final ySteps = (yMax / interval).toInt();
    const chartHeight = 170.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rangeStartDate =
        DateTime(_rangeStart.year, _rangeStart.month, _rangeStart.day);
    final todayIndex = today.difference(rangeStartDate).inDays;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        decoration: BoxDecoration(
          color: heroCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Weekly Overview',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: chartHeight,
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(ySteps + 1, (i) {
                        final value = (ySteps - i) * interval;
                        return Text(
                          '${value.toInt()}m',
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: darkTextMuted,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _barAnim,
                      builder: (context, _) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final h = constraints.maxHeight;
                            return Stack(
                              children: [
                                ...List.generate(ySteps + 1, (i) {
                                  final y = (i / ySteps) * h;
                                  return Positioned(
                                    top: y,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                        height: 0.5, color: darkDivider),
                                  );
                                }),
                                Positioned.fill(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: List.generate(7, (i) {
                                      final val = weeklyBarData[i];
                                      final fullBarH =
                                          yMax > 0 ? (val / yMax) * h : 0.0;
                                      final stagger = (i / 7.0) * 0.3;
                                      final progress =
                                          ((_barAnim.value - stagger) /
                                                  (1.0 - stagger))
                                              .clamp(0.0, 1.0);
                                      final barH = fullBarH * progress;
                                      final isToday = i == todayIndex;

                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Container(
                                            height: barH > 0 ? barH : 0,
                                            decoration: BoxDecoration(
                                              gradient: val > 0
                                                  ? LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: isToday
                                                          ? [
                                                              accentCoral,
                                                              accentCoralDark
                                                            ]
                                                          : [
                                                              accentCoral
                                                                  .withValues(
                                                                      alpha:
                                                                          0.8),
                                                              accentCoral
                                                                  .withValues(
                                                                      alpha:
                                                                          0.5),
                                                            ],
                                                    )
                                                  : null,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                              ),
                                              boxShadow: isToday && val > 0
                                                  ? [
                                                      BoxShadow(
                                                        color: accentCoral
                                                            .withValues(
                                                                alpha: 0.35),
                                                        blurRadius: 10,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                children: List.generate(7, (i) {
                  final isToday = i == todayIndex;
                  final dayDate = _rangeStart.add(Duration(days: i));
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          _dayLabels[i],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isToday ? accentCoral : darkTextMuted,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${dayDate.day.toString().padLeft(2, '0')}/${dayDate.month.toString().padLeft(2, '0')}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? accentCoral
                                : darkTextMuted.withValues(alpha: 0.6),
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: accentCoral,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList(AsyncValue<List<PracticeSession>> sessionsAsync) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Recent Sessions',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAllSessions(
                        context, sessionsAsync.valueOrNull ?? []),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        'View All',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accentCoral,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            sessionsAsync.when(
              data: (sessions) => sessions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Center(
                        child: Text(
                          'No sessions in this period',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkTextSecondary,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: List.generate(sessions.length, (i) {
                        final s = sessions[i];
                        final instIcon = _instrumentIcons[s.instrumentName] ??
                            Icons.music_note;
                        return Column(
                          children: [
                            const Divider(
                              height: 1,
                              color: darkDivider,
                              indent: 16,
                              endIndent: 16,
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
                                    child: Icon(instIcon,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.instrumentName,
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          _formatSessionDate(s.startedAt),
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: darkTextMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatSessionDuration(s.durationSeconds),
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: accentCoral),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Text(
                  'Could not load sessions.',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkTextMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  // --- Student Recordings (teacher view, play only) ---
  Widget _buildRecordingsList() {
    final recordingsAsync = ref.watch(
      studentRecordingsProvider(studentId: widget.studentId),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Recordings',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAllRecordings(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        'View All',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accentCoral,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            recordingsAsync.when(
              data: (recordings) => recordings.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Center(
                        child: Text(
                          'No recordings yet',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkTextSecondary,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: recordings.take(5).map((recording) {
                        return RecordingListTile(
                          recording: recording,
                          onPlay: () => _playRecording(recording),
                        );
                      }).toList(),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: accentCoral,
                    ),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Text(
                  'Could not load recordings.',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkTextMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Future<void> _playRecording(PracticeRecording recording) async {
    try {
      final url = await ref
          .read(recordingServiceProvider)
          .getSignedUrl(recording.filePath);
      if (mounted) {
        showRecordingPlayer(
          context,
          url: url,
          instrumentName: recording.instrumentName,
          date: _formatSessionDate(recording.createdAt),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not play recording',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF1E0E3D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAllRecordings() {
    final recordingsAsync = ref.read(
      studentRecordingsProvider(studentId: widget.studentId),
    );
    final recordings = recordingsAsync.valueOrNull ?? [];
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E0E3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 5),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                'All Recordings',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${recordings.length} recording${recordings.length == 1 ? '' : 's'}',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: darkTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                ),
                child: recordings.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No recordings yet',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkTextSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: recordings.length,
                        itemBuilder: (context, i) {
                          final recording = recordings[i];
                          return RecordingListTile(
                            recording: recording,
                            onPlay: () => _playRecording(recording),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Close',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: accentCoral,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRemoveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _confirmRemoveStudent(),
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
            'Remove Student',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveStudent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0E3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Student',
          style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${widget.studentName} from your group?',
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
            child: Text('Remove',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(groupServiceProvider)
          .removeStudent(widget.groupId!, widget.studentId);
      ref.invalidate(unreadGroupNotificationsProvider);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  void _showAllSessions(BuildContext context, List<PracticeSession> sessions) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E0E3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 5),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                'All Sessions',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${sessions.length} session${sessions.length == 1 ? '' : 's'}',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: darkTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                ),
                child: sessions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No recent sessions yet',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkTextSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: sessions.length,
                        itemBuilder: (context, i) {
                          final s = sessions[i];
                          final instIcon =
                              _instrumentIcons[s.instrumentName] ??
                                  Icons.music_note;
                          return Column(
                            children: [
                              const Divider(
                                height: 1,
                                color: darkDivider,
                                indent: 16,
                                endIndent: 16,
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
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black,
                                            width: 2),
                                      ),
                                      child: Icon(instIcon,
                                          color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.instrumentName,
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            _formatSessionDate(s.startedAt),
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: darkTextMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatSessionDuration(
                                          s.durationSeconds),
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Close',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: accentCoral,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
