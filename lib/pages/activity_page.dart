import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/models/practice_session.dart';
import 'package:listzly/models/practice_recording.dart';
import 'package:listzly/providers/session_provider.dart';
import 'package:listzly/providers/recording_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/models/user_role.dart';
import 'package:listzly/components/recording_list_tile.dart';
import 'package:listzly/components/recording_player.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/providers/subscription_provider.dart';
import 'package:listzly/components/upgrade_prompt.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';

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
    final tier = ref.watch(effectiveSubscriptionTierProvider);

    // Lock entire activity page for free users
    if (!tier.canViewActivity) {
      return Scaffold(
        backgroundColor: const Color(0xFF150833),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentCoral.withAlpha(40),
                          accentCoralDark.withAlpha(40),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 40,
                      color: accentCoral,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Activity',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your practice sessions, view stats, and manage recordings with Pro.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => showUpgradePrompt(context, feature: 'Activity'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF4A68E), accentCoralDark],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accentCoral.withAlpha(80),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        'Upgrade to Pro',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Watch providers using the current date range
    final sessionsAsync = ref.watch(
      sessionListProvider(start: _rangeStart, end: _rangeEnd),
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
              SliverToBoxAdapter(child: _buildBarChart(sessionsAsync)),

              // Recent sessions list
              SliverToBoxAdapter(child: _buildSessionList(sessionsAsync)),

              // My Recordings
              SliverToBoxAdapter(child: _buildRecordingsList()),

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
  Widget _buildBarChart(AsyncValue<List<PracticeSession>> sessionsAsync) {
    return sessionsAsync.when(
      data: (sessions) {
        final chart = _computeChartData(sessions);
        return _buildBarChartContent(chart.values, chart.labels, chart.sublabels, chart.highlightIndex);
      },
      loading: () {
        final chart = _computeChartData([]);
        return _buildBarChartContent(chart.values, chart.labels, chart.sublabels, chart.highlightIndex);
      },
      error: (_, _) {
        final chart = _computeChartData([]);
        return _buildBarChartContent(chart.values, chart.labels, chart.sublabels, chart.highlightIndex);
      },
    );
  }

  ({List<double> values, List<String> labels, List<String>? sublabels, int highlightIndex}) _computeChartData(List<PracticeSession> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedTab) {
      case 1: // Month – one bar per week chunk (days 1-7, 8-14, …)
        final daysInMonth = DateTime(_rangeStart.year, _rangeStart.month + 1, 0).day;
        final weekCount = ((daysInMonth - 1) ~/ 7) + 1;
        final values = List<double>.filled(weekCount, 0.0);
        final labels = <String>[];
        final sublabels = <String>[];
        for (var w = 0; w < weekCount; w++) {
          final startDay = w * 7 + 1;
          final endDay = ((w + 1) * 7).clamp(1, daysInMonth);
          labels.add('WK ${w + 1}');
          sublabels.add('$startDay–$endDay');
        }
        for (final session in sessions) {
          final completed = session.completedAt ?? session.startedAt;
          final weekIndex = (completed.day - 1) ~/ 7;
          if (weekIndex < weekCount) {
            values[weekIndex] += (session.durationSeconds ~/ 60).toDouble();
          }
        }
        var monthHighlight = -1;
        if (_rangeStart.year == today.year && _rangeStart.month == today.month) {
          monthHighlight = (today.day - 1) ~/ 7;
        }
        return (values: values, labels: labels, sublabels: sublabels, highlightIndex: monthHighlight);

      case 2: // Year – one bar per month
        final values = List<double>.filled(12, 0.0);
        const labels = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
        for (final session in sessions) {
          final completed = session.completedAt ?? session.startedAt;
          final monthIndex = completed.month - 1;
          values[monthIndex] += (session.durationSeconds ~/ 60).toDouble();
        }
        var yearHighlight = -1;
        if (_rangeStart.year == today.year) {
          yearHighlight = today.month - 1;
        }
        return (values: values, labels: labels, sublabels: null, highlightIndex: yearHighlight);

      default: // Week – one bar per day (SUN–SAT)
        final values = List<double>.filled(7, 0.0);
        final rangeStartDate = DateTime(_rangeStart.year, _rangeStart.month, _rangeStart.day);
        for (final session in sessions) {
          final completed = session.completedAt ?? session.startedAt;
          final day = DateTime(completed.year, completed.month, completed.day);
          final index = day.difference(rangeStartDate).inDays;
          if (index >= 0 && index < 7) {
            values[index] += (session.durationSeconds ~/ 60).toDouble();
          }
        }
        final weekHighlight = today.difference(rangeStartDate).inDays;
        final sublabels = List.generate(7, (i) {
          final d = _rangeStart.add(Duration(days: i));
          return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
        });
        return (values: values, labels: _dayLabels.toList(), sublabels: sublabels, highlightIndex: weekHighlight);
    }
  }

  Widget _buildBarChartContent(List<double> barData, List<String> barLabels, List<String>? barSublabels, int highlightIndex) {
    final barCount = barData.length;
    final dataMax =
        barData.reduce((a, b) => a > b ? a : b).ceilToDouble();
    // Round y-axis max up to a nice interval for minutes
    final rawMax = dataMax < 30 ? 30.0 : dataMax;
    final interval = rawMax <= 15 ? 5.0 : rawMax <= 30 ? 10.0 : rawMax <= 60 ? 15.0 : 30.0;
    final yMax = (rawMax / interval).ceil() * interval;
    final ySteps = (yMax / interval).toInt();
    const chartHeight = 170.0;

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
                _selectedTab == 0
                    ? 'Weekly Overview'
                    : _selectedTab == 1
                        ? 'Monthly Overview'
                        : 'Yearly Overview',
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
                                    children: List.generate(barCount, (i) {
                                      final val = barData[i];
                                      final fullBarH = yMax > 0
                                          ? (val / yMax) * h
                                          : 0.0;
                                      // Stagger: each bar starts slightly after the previous
                                      final stagger =
                                          (i / barCount.toDouble()) * 0.3;
                                      final progress = ((_barAnim.value -
                                                  stagger) /
                                              (1.0 - stagger))
                                          .clamp(0.0, 1.0);
                                      final barH = fullBarH * progress;
                                      final isToday = i == highlightIndex;

                                      return Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: barCount > 7 ? 2 : 5),
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
            // X-axis labels
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                children: List.generate(
                  barCount,
                  (i) {
                    final isHighlighted = i == highlightIndex;
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            barLabels[i],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: barCount > 7 ? 8 : 10,
                              fontWeight: FontWeight.w700,
                              color: isHighlighted
                                  ? accentCoral
                                  : darkTextMuted,
                            ),
                          ),
                          if (barSublabels != null) ...[
                            const SizedBox(height: 1),
                            Text(
                              barSublabels[i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: barCount > 7 ? 7 : 9,
                                fontWeight: FontWeight.w600,
                                color: isHighlighted
                                    ? accentCoral
                                    : darkTextMuted.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                          if (isHighlighted) ...[
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
                          context, sessionsAsync.value ?? []);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // --- My Recordings section ---
  Widget _buildRecordingsList() {
    final tier = ref.watch(effectiveSubscriptionTierProvider);

    // Free users see locked card
    if (!tier.canRecord) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: GestureDetector(
          onTap: () => showUpgradePrompt(context, feature: 'Recordings'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: darkCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: darkSurfaceBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.white54, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Recordings',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Upgrade to Pro to record your practice',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: darkTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: darkTextMuted),
              ],
            ),
          ),
        ),
      );
    }

    final recordingsAsync = ref.watch(userRecordingsProvider);
    final role = ref.watch(currentProfileProvider).value?.role;
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
                    'My Recordings',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _showAllRecordings(
                          recordingsAsync.value ?? []);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'Recordings are automatically deleted after 30 days.',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: darkTextMuted,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Recording rows
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
                          onToggleShare: role == UserRole.student
                              ? () => _toggleShareRecording(recording)
                              : null,
                          onDownload: () => _downloadRecording(recording),
                          onDelete: () => _confirmDeleteRecording(recording),
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
              error: (_, _) => Padding(
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

  Future<void> _downloadRecording(PracticeRecording recording) async {
    try {
      final url = await ref
          .read(recordingServiceProvider)
          .getSignedUrl(recording.filePath);

      // Download file to temp directory
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      final bytes = await response.fold<List<int>>(
        [],
        (prev, chunk) => prev..addAll(chunk),
      );
      httpClient.close();

      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${recording.instrumentName}_${recording.createdAt.millisecondsSinceEpoch}.m4a';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Open native Save As dialog
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      await FlutterFileDialog.saveFile(params: params);
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not download recording: $e',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: accentCoralDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleShareRecording(PracticeRecording recording) async {
    final newShared = !recording.sharedWithTeacher;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E0E3D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                newShared ? 'Share with Teacher?' : 'Unshare with Teacher?',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                newShared
                    ? 'Your teacher will be able to listen to this recording.'
                    : 'Your teacher will no longer be able to listen to this recording.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          color: darkTextMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: newShared ? accentCoral : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        newShared ? 'Share' : 'Unshare',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(recordingServiceProvider).setShared(
            recording.id!,
            newShared,
          );
      ref.invalidate(userRecordingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newShared
                  ? 'Recording shared with teacher'
                  : 'Recording unshared',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: accentCoralDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not update sharing',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: accentCoralDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteRecording(PracticeRecording recording) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E0E3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Recording',
          style:
              GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this recording? This cannot be undone.',
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
            child: Text('Delete',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(recordingServiceProvider).deleteRecording(
              recording.id!,
              recording.filePath,
            );
        ref.invalidate(userRecordingsProvider);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not delete recording',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF1E0E3D),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
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

  void _showAllRecordings(List<PracticeRecording> recordings) {
    final role = ref.read(currentProfileProvider).value?.role;
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
                            onToggleShare: role == UserRole.student
                                ? () => _toggleShareRecording(recording)
                                : null,
                            onDownload: () => _downloadRecording(recording),
                            onDelete: () {
                              _confirmDeleteRecording(recording);
                            },
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
