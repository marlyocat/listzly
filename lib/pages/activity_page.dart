import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with TickerProviderStateMixin {
  int _selectedTab = 0;

  // Bar chart animation
  late final AnimationController _barAnimController;
  late final Animation<double> _barAnim;

  // Mock bar chart data (sessions per day for the current week)
  final List<double> _weeklyBarData = [1, 0, 1, 2, 0, 3, 1];
  final List<String> _barLabels = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  // Mock contribution heat map (7 days x 26 weeks)
  late final List<List<double>> _heatMapData;

  // Mock recent sessions
  final List<_Session> _sessions = const [
    _Session(
        date: '12 Feb 2026',
        duration: '45m 30s',
        count: 2,
        instrument: 'Piano'),
    _Session(
        date: '11 Feb 2026',
        duration: '30m 15s',
        count: 1,
        instrument: 'Guitar'),
    _Session(
        date: '10 Feb 2026',
        duration: '1h 10m',
        count: 2,
        instrument: 'Violin'),
    _Session(
        date: '9 Feb 2026',
        duration: '25m',
        count: 1,
        instrument: 'Piano'),
    _Session(
        date: '8 Feb 2026',
        duration: '50m',
        count: 1,
        instrument: 'Drums'),
    _Session(
        date: '7 Feb 2026',
        duration: '35m',
        count: 1,
        instrument: 'Guitar'),
    _Session(
        date: '6 Feb 2026',
        duration: '40m',
        count: 1,
        instrument: 'Piano'),
  ];

  @override
  void initState() {
    super.initState();

    // Heat map data
    final rng = Random(42);
    _heatMapData = List.generate(
      7,
      (day) => List.generate(
        26,
        (week) => rng.nextDouble() < 0.35 ? 0.0 : rng.nextDouble(),
      ),
    );

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

  // Instrument icon mapping
  static const _instrumentIcons = {
    'Piano': Icons.piano,
    'Guitar': Icons.music_note,
    'Violin': Icons.library_music,
    'Drums': Icons.surround_sound,
  };

  static const _instrumentColors = {
    'Piano': Color(0xFFF4A68E),
    'Guitar': Color(0xFF7C3AED),
    'Violin': Color(0xFF60A5FA),
    'Drums': Color(0xFFFBBF24),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkest,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: activityGradientColors,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Title with gradient text
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFF4A68E)],
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
              SliverToBoxAdapter(child: _buildDateStats()),

              // Summary stats row
              SliverToBoxAdapter(child: _buildSummaryStats()),

              // Bar chart
              SliverToBoxAdapter(child: _buildBarChart()),

              // Contribution heat map
              SliverToBoxAdapter(child: _buildContributionGraph()),

              // Recent sessions list
              SliverToBoxAdapter(child: _buildSessionList()),

              // Bottom spacing for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
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
          border: Border.all(color: darkCardBorder, width: 0.5),
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
                        onTap: () => setState(() => _selectedTab = i),
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
  Widget _buildDateStats() {
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
                  'Feb 6 \u2013 12, 2026',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '9 Sessions',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accentCoral,
                  ),
                ),
              ],
            ),
          ),
          // Navigation arrows for date range
          Row(
            children: [
              _buildCircleIconButton(Icons.chevron_left),
              const SizedBox(width: 8),
              _buildCircleIconButton(Icons.chevron_right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: darkSurfaceBg,
        shape: BoxShape.circle,
        border: Border.all(color: darkCardBorder),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  // --- Summary stats row ---
  Widget _buildSummaryStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.access_time_rounded,
            value: '4h 35m',
            label: 'Total Time',
            color: accentCoral,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            icon: Icons.music_note_rounded,
            value: '9',
            label: 'Sessions',
            color: primaryLight,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            value: '3',
            label: 'Best Day',
            color: const Color(0xFFFBBF24),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: darkCardBorder, width: 0.5),
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
              ),
              child: Icon(icon, color: color, size: 19),
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
    );
  }

  // --- Animated bar chart with gradient fill ---
  Widget _buildBarChart() {
    final dataMax =
        _weeklyBarData.reduce((a, b) => a > b ? a : b).ceilToDouble();
    final yMax = (dataMax + 1).clamp(2, 100).toDouble();
    final ySteps = yMax.toInt();
    const chartHeight = 170.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
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
                  // Y-axis labels
                  SizedBox(
                    width: 22,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        ySteps + 1,
                        (i) => Text(
                          '${ySteps - i}',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: darkTextMuted,
                          ),
                        ),
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
                                      final val = _weeklyBarData[i];
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
                                      final isToday = i == 5; // Friday

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
            // X-axis labels
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: List.generate(
                  7,
                  (i) {
                    final isToday = i == 5;
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            _barLabels[i],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isToday
                                  ? accentCoral
                                  : darkTextMuted,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(height: 3),
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

  // --- Contribution dot grid (GitHub-style) with coral gradient ---
  Widget _buildContributionGraph() {
    const weeks = 26;
    const cellSize = 10.0;
    const gap = 3.0;
    const totalW = weeks * (cellSize + gap) - gap;
    final months = ['SEP', 'OCT', 'NOV', 'DEC', 'JAN', 'FEB'];
    const monthSpacing = totalW / 6;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: darkCardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Practice History',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // Legend
                _buildHeatLegendDot(darkSurfaceBg, 'None'),
                const SizedBox(width: 8),
                _buildHeatLegendDot(
                    accentCoral.withValues(alpha: 0.35), 'Low'),
                const SizedBox(width: 8),
                _buildHeatLegendDot(
                    accentCoral.withValues(alpha: 0.65), 'Med'),
                const SizedBox(width: 8),
                _buildHeatLegendDot(accentCoral, 'High'),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month labels
                  SizedBox(
                    width: totalW,
                    child: Row(
                      children: months
                          .map(
                            (m) => SizedBox(
                              width: monthSpacing,
                              child: Text(
                                m,
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: darkTextMuted,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Dot grid: 7 rows x 26 columns
                  ...List.generate(7, (day) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: day < 6 ? gap : 0),
                      child: Row(
                        children: List.generate(weeks, (week) {
                          final val = _heatMapData[day][week];
                          return Container(
                            width: cellSize,
                            height: cellSize,
                            margin: EdgeInsets.only(
                              right: week < weeks - 1 ? gap : 0,
                            ),
                            decoration: BoxDecoration(
                              color: val == 0
                                  ? darkSurfaceBg
                                  : accentCoral.withValues(
                                      alpha: 0.15 + val * 0.85),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: darkTextSecondary,
          ),
        ),
      ],
    );
  }

  // --- Recent sessions list with instrument icons ---
  Widget _buildSessionList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: darkCardBorder, width: 0.5),
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
                  Container(
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
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Session rows
            ...List.generate(_sessions.length, (i) {
              final s = _sessions[i];
              final instColor =
                  _instrumentColors[s.instrument] ?? accentCoral;
              final instIcon =
                  _instrumentIcons[s.instrument] ?? Icons.music_note;
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
                          ),
                          child: Icon(instIcon, color: instColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        // Date + instrument name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.instrument,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                s.date,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: darkTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Duration + session count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              s.duration,
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (s.count > 1) ...[
                              const SizedBox(height: 1),
                              Text(
                                '${s.count} sessions',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: darkTextMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right,
                          color: darkTextSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _Session {
  final String date;
  final String duration;
  final int count;
  final String instrument;

  const _Session({
    required this.date,
    required this.duration,
    required this.count,
    required this.instrument,
  });
}
