import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _selectedTab = 0;

  // Mock bar chart data (sessions per day for the current week)
  final List<double> _weeklyBarData = [1, 0, 1, 2, 0, 3, 1];
  final List<String> _barLabels = [
    'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT',
  ];

  // Mock contribution heat map (7 days × 26 weeks)
  late final List<List<double>> _heatMapData;

  // Mock recent sessions
  final List<_Session> _sessions = const [
    _Session(date: '12 Feb 2026', duration: '45m 30s', count: 2),
    _Session(date: '11 Feb 2026', duration: '30m 15s', count: 1),
    _Session(date: '10 Feb 2026', duration: '1h 10m', count: 2),
    _Session(date: '9 Feb 2026', duration: '25m', count: 1),
    _Session(date: '8 Feb 2026', duration: '50m', count: 1),
    _Session(date: '7 Feb 2026', duration: '35m', count: 1),
    _Session(date: '6 Feb 2026', duration: '40m', count: 1),
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random(42);
    _heatMapData = List.generate(
      7,
      (day) => List.generate(
        26,
        (week) => rng.nextDouble() < 0.35 ? 0.0 : rng.nextDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  'Activity',
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            // Week / Month / Year tabs
            SliverToBoxAdapter(child: _buildSegmentedTabs()),

            // Date range + session count
            SliverToBoxAdapter(child: _buildDateStats()),

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
    );
  }

  // ─── Week / Month / Year segmented control ───────────────────────
  Widget _buildSegmentedTabs() {
    const labels = ['Week', 'Month', 'Year'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: List.generate(3, (i) {
            final selected = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Date range + session stat ────────────────────────────────────
  Widget _buildDateStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feb 6 – 12, 2026',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
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
    );
  }

  // ─── Bar chart ────────────────────────────────────────────────────
  Widget _buildBarChart() {
    // Determine a nice max for the y-axis (at least 1 above the data max)
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: [
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
                            color: const Color(0xFFCCCCCC),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bars + gridlines
                  Expanded(
                    child: LayoutBuilder(
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
                                  height: 1,
                                  color: const Color(0xFFF3F3F3),
                                ),
                              );
                            }),
                            // Bars
                            Positioned.fill(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(7, (i) {
                                  final val = _weeklyBarData[i];
                                  final barH =
                                      yMax > 0 ? (val / yMax) * h : 0.0;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Container(
                                        height: barH > 0 ? barH : 0,
                                        decoration: BoxDecoration(
                                          color: val > 0
                                              ? accentCoral
                                              : Colors.transparent,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
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
                  (i) => Expanded(
                    child: Text(
                      _barLabels[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Contribution dot grid (GitHub-style, spanning ~6 months) ────
  Widget _buildContributionGraph() {
    const weeks = 26;
    const cellSize = 10.0;
    const gap = 3.0;
    const totalW = weeks * (cellSize + gap) - gap;
    final months = ['SEP', 'OCT', 'NOV', 'DEC', 'JAN', 'FEB'];
    // Approximate spacing: 26 weeks / 6 months ≈ 4.3 weeks each
    const monthSpacing = totalW / 6;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practice History',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
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
                                  color: const Color(0xFFBBBBBB),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Dot grid: 7 rows × 26 columns
                  ...List.generate(7, (day) {
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: day < 6 ? gap : 0),
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
                                  ? const Color(0xFFEEEEEE)
                                  : primaryColor.withValues(
                                      alpha: 0.2 + val * 0.6),
                              shape: BoxShape.circle,
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

  // ─── Recent sessions list ─────────────────────────────────────────
  Widget _buildSessionList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
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
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View All',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Session rows
            ...List.generate(_sessions.length, (i) {
              final s = _sessions[i];
              return Column(
                children: [
                  const Divider(
                    height: 1,
                    color: Color(0xFFF0F0F0),
                    indent: 16,
                    endIndent: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.date,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ),
                        Text(
                          s.duration,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFFCCCCCC),
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

  const _Session({
    required this.date,
    required this.duration,
    required this.count,
  });
}
