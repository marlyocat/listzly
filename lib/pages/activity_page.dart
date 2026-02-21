import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/models/practice_session.dart';
import 'package:listzly/providers/session_provider.dart';
import 'package:listzly/theme/colors.dart';

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage>
    with TickerProviderStateMixin {
  int _selectedTab = 0;

  // Bar chart animation
  late final AnimationController _barAnimController;
  late final Animation<double> _barAnim;

  static const _dayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  // Instrument icon mapping
  static const _instrumentIcons = {
    'Piano': Icons.piano,
    'Guitar': Icons.music_note,
    'Violin': Icons.library_music,
    'Drums': Icons.surround_sound,
  };

  // ---- Date range state ----

  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();

    _computeDateRange();

    // Bar chart entrance animation
    _barAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnim = CurvedAnimation(
      parent: _barAnimController,
      curve: Curves.easeOutCubic,
    );
    // Delay slightly so it feels natural as the user scrolls into view
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _barAnimController.forward();
    });
  }

  @override
  void dispose() {
    _barAnimController.dispose();
    super.dispose();
  }

  /// Recompute [_rangeStart] and [_rangeEnd] based on the current
  /// [_selectedTab] (0 = week, 1 = month, 2 = year) anchored to today.
  void _computeDateRange() {
    final now = DateTime.now();
    switch (_selectedTab) {
      case 0: // Week (Sunday – Saturday containing today)
        final weekday = now.weekday % 7; // Sun=0 .. Sat=6
        _rangeStart = DateTime(now.year, now.month, now.day - weekday);
        _rangeEnd = _rangeStart.add(const Duration(days: 6));
        break;
      case 1: // Month
        _rangeStart = DateTime(now.year, now.month);
        _rangeEnd = DateTime(now.year, now.month + 1)
            .subtract(const Duration(days: 1));
        break;
      case 2: // Year
        _rangeStart = DateTime(now.year);
        _rangeEnd = DateTime(now.year, 12, 31);
        break;
    }
  }

  /// Shift the current range backward by one period.
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

  /// Shift the current range forward by one period.
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

  // ---- Date picker ----

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _rangeStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(9999, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accentCoral,
              onPrimary: Colors.white,
              surface: Color(0xFF1E0E3D),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E0E3D),
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: accentCoral,
              selectionColor: accentCoral,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Color(0xFF1E0E3D),
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStatePropertyAll(Colors.white),
              yearForegroundColor: WidgetStatePropertyAll(Colors.white),
              weekdayStyle: TextStyle(color: Colors.white70),
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white70),
                fillColor: Color(0xFF2A1650),
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accentCoral),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      switch (_selectedTab) {
        case 0: // Week: jump to the week containing the picked date
          final weekday = picked.weekday % 7; // Sun=0 .. Sat=6
          _rangeStart = DateTime(picked.year, picked.month, picked.day - weekday);
          _rangeEnd = _rangeStart.add(const Duration(days: 6));
          break;
        case 1: // Month: jump to the month of the picked date
          _rangeStart = DateTime(picked.year, picked.month);
          _rangeEnd = DateTime(picked.year, picked.month + 1)
              .subtract(const Duration(days: 1));
          break;
        case 2: // Year: jump to the year of the picked date
          _rangeStart = DateTime(picked.year);
          _rangeEnd = DateTime(picked.year, 12, 31);
          break;
      }
      _restartBarAnimation();
    });
  }

  // ---- Formatting helpers ----

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

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
    // Watch providers using the current date range
    final sessionsAsync = ref.watch(
      sessionListProvider(start: _rangeStart, end: _rangeEnd),
    );
    final barDataAsync = ref.watch(
      weeklyBarDataProvider(weekStart: _rangeStart),
    );
    final statsAsync = ref.watch(
      summaryStatsProvider(start: _rangeStart, end: _rangeEnd),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
              // Title with gradient text
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
                      'Activity',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Week / Month / Year tabs
              SliverToBoxAdapter(child: _buildSegmentedTabs()),

              // Date range + session count
              SliverToBoxAdapter(child: _buildDateStats(statsAsync)),

              // Summary stats row
              SliverToBoxAdapter(child: _buildSummaryStats(statsAsync)),

              // Bar chart
              SliverToBoxAdapter(child: _buildBarChart(barDataAsync)),

              // Recent sessions list
              SliverToBoxAdapter(child: _buildSessionList(sessionsAsync)),

              // Bottom spacing for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
    );
  }

  // --- Week / Month / Year segmented control with animated indicator ---
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
                // Animated sliding indicator
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
                // Tab labels
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
                              color: selected
                                  ? Colors.white
                                  : darkTextMuted,
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

  // --- Date range + session stat ---
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
                GestureDetector(
                  onTap: () => _showDatePicker(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDateRange(),
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.calendar_today_rounded,
                        color: darkTextMuted,
                        size: 16,
                      ),
                    ],
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
                  error: (_, _) => Text(
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
          // Navigation arrows for date range
          Row(
            children: [
              _buildCircleIconButton(Icons.chevron_left, onTap: _shiftRangeBack),
              const SizedBox(width: 8),
              _buildCircleIconButton(Icons.chevron_right, onTap: _shiftRangeForward),
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

  // --- Summary stats row ---
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
              color: accentCoral,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              icon: Icons.music_note_rounded,
              value: '\u2014',
              label: 'Sessions',
              color: primaryLight,
            ),
          ],
        ),
        error: (_, _) => Row(
          children: [
            _buildStatCard(
              icon: Icons.access_time_rounded,
              value: '\u2014',
              label: 'Total Time',
              color: accentCoral,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              icon: Icons.music_note_rounded,
              value: '\u2014',
              label: 'Sessions',
              color: primaryLight,
            ),
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

  // --- Animated bar chart with gradient fill ---
  Widget _buildBarChart(AsyncValue<Map<DateTime, int>> barDataAsync) {
    return barDataAsync.when(
      data: (barMap) => _buildBarChartContent(_barMapToList(barMap)),
      loading: () => _buildBarChartContent(List.filled(7, 0.0)),
      error: (_, _) => _buildBarChartContent(List.filled(7, 0.0)),
    );
  }

  /// Convert the [Map<DateTime, int>] from the provider into a 7-element list
  /// ordered Sunday..Saturday matching the week starting at [_rangeStart].
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
    // Round y-axis max up to a nice interval for minutes
    final rawMax = dataMax < 30 ? 30.0 : dataMax;
    final interval = rawMax <= 15 ? 5.0 : rawMax <= 30 ? 10.0 : rawMax <= 60 ? 15.0 : 30.0;
    final yMax = (rawMax / interval).ceil() * interval;
    final ySteps = (yMax / interval).toInt();
    const chartHeight = 170.0;

    // Determine which bar index represents today (if today falls within the range)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rangeStartDate = DateTime(_rangeStart.year, _rangeStart.month, _rangeStart.day);
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
            // Section label
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
            // Chart area
            SizedBox(
              height: chartHeight,
              child: Row(
                children: [
                  // Y-axis labels (minutes)
                  SizedBox(
                    width: 32,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        ySteps + 1,
                        (i) {
                          final value = (ySteps - i) * interval;
                          return Text(
                            '${value.toInt()}m',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: darkTextMuted,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bars + gridlines
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _barAnim,
                      builder: (context, _) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final h = constraints.maxHeight;
                            return Stack(
                              children: [
                                // Horizontal gridlines
                                ...List.generate(ySteps + 1, (i) {
                                  final y = (i / ySteps) * h;
                                  return Positioned(
                                    top: y,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 0.5,
                                      color: darkDivider,
                                    ),
                                  );
                                }),
                                // Bars with staggered entrance animation
                                Positioned.fill(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: List.generate(7, (i) {
                                      final val = weeklyBarData[i];
                                      final fullBarH = yMax > 0
                                          ? (val / yMax) * h
                                          : 0.0;
                                      // Stagger: each bar starts slightly after the previous
                                      final stagger =
                                          (i / 7.0) * 0.3; // 0..0.3
                                      final progress = ((_barAnim.value -
                                                  stagger) /
                                              (1.0 - stagger))
                                          .clamp(0.0, 1.0);
                                      final barH = fullBarH * progress;
                                      final isToday = i == todayIndex;

                                      return Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                          child: Container(
                                            height:
                                                barH > 0 ? barH : 0,
                                            decoration: BoxDecoration(
                                              gradient: val > 0
                                                  ? LinearGradient(
                                                      begin: Alignment
                                                          .topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: isToday
                                                          ? [
                                                              accentCoral,
                                                              accentCoralDark,
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
                                                  const BorderRadius
                                                      .vertical(
                                                top:
                                                    Radius.circular(6),
                                              ),
                                              boxShadow: isToday &&
                                                      val > 0
                                                  ? [
                                                      BoxShadow(
                                                        color: accentCoral
                                                            .withValues(
                                                                alpha:
                                                                    0.35),
                                                        blurRadius: 10,
                                                        offset:
                                                            const Offset(
                                                                0, 2),
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
            // X-axis labels (day + date)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                children: List.generate(
                  7,
                  (i) {
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
                              color: isToday
                                  ? accentCoral
                                  : darkTextMuted,
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Recent sessions list with instrument icons ---
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
            // Header
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
                    onTap: () {
                      _showAllSessions(
                          context, sessionsAsync.valueOrNull ?? []);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
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
            // Session rows
            sessionsAsync.when(
              data: (sessions) => sessions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Center(
                        child: Text(
                          'No recent sessions yet',
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
                  final instIcon =
                      _instrumentIcons[s.instrumentName] ?? Icons.music_note;
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
                            // Instrument icon
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: darkSurfaceBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Icon(instIcon, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            // Date + instrument name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            // Duration
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
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
                      strokeWidth: 2.5,
                      color: accentCoral,
                    ),
                  ),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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

  void _showAllSessions(BuildContext context, List<PracticeSession> sessions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
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
              child: Column(
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
                  Expanded(
                    child: sessions.isEmpty
                        ? Center(
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
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).padding.bottom + 16,
                      ),
                      itemCount: sessions.length,
                      itemBuilder: (context, i) {
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
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
