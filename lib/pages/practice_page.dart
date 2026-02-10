import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class PracticePage extends StatefulWidget {
  final String instrument;
  final IconData instrumentIcon;
  final int durationMinutes;

  const PracticePage({
    super.key,
    required this.instrument,
    required this.instrumentIcon,
    required this.durationMinutes,
  });

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage>
    with TickerProviderStateMixin {
  static const _quotes = [
    {'quote': 'Every note you play is a step closer to mastery.', 'author': 'Unknown'},
    {'quote': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs'},
    {'quote': 'Practice does not make perfect. Practice makes permanent.', 'author': 'Bobby Robson'},
    {'quote': 'Music expresses that which cannot be said.', 'author': 'Victor Hugo'},
    {'quote': 'It is not enough to do your best; you must know what to do, and then do your best.', 'author': 'W. Edwards Deming'},
    {'quote': 'The beautiful thing about learning is nobody can take it away from you.', 'author': 'B.B. King'},
    {'quote': 'Without craftsmanship, inspiration is a mere reed shaken in the wind.', 'author': 'Johannes Brahms'},
    {'quote': 'Genius is one percent inspiration and ninety-nine percent perspiration.', 'author': 'Thomas Edison'},
    {'quote': 'Where words fail, music speaks.', 'author': 'Hans Christian Andersen'},
    {'quote': 'One who plays wrong notes is a beginner; one who hesitates is an amateur.', 'author': 'Unknown'},
  ];

  late int _remainingSeconds;
  Timer? _timer;
  Timer? _quoteTimer;
  bool _isPaused = false;
  bool _sessionCompleted = false;
  late int _quoteIndex;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _quoteIndex = Random().nextInt(_quotes.length);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _startTimer();
    _startQuoteRotation();
  }

  void _startQuoteRotation() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isPaused) {
        setState(() => _quoteIndex = (_quoteIndex + 1) % _quotes.length);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _sessionCompleted = true);
        _onSessionComplete();
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
        _pulseController.repeat(reverse: true);
        _rippleController.repeat();
      } else {
        _pulseController.stop();
        _rippleController.stop();
        _startTimer();
      }
    });
  }

  void _onSessionComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D1066),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Session Complete!',
          style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 24),
        ),
        content: Text(
          '${widget.durationMinutes} minutes of ${widget.instrument.toLowerCase()} practice recorded.',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(this.context).pop(true);
            },
            child: Text(
              'Done',
              style: TextStyle(color: const Color(0xFFF4A68E), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_sessionCompleted) return true;

    _timer?.cancel();
    final wasPaused = _isPaused;
    setState(() => _isPaused = true);

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D1066),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'End Session?',
          style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 24),
        ),
        content: const Text(
          'This session will not be counted if you leave now.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Resume',
              style: TextStyle(color: const Color(0xFFF4A68E), fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave == true) return true;

    // Resume if it wasn't paused before
    if (!wasPaused) {
      setState(() => _isPaused = false);
      _startTimer();
    }
    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quoteTimer?.cancel();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF9333EA),
                primaryColor,
                const Color(0xFF4A1D8E),
                const Color(0xFF2D1066),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    const Spacer(flex: 3),

                    // Large countdown timer
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFCE4DC), Color(0xFFF4A68E)],
                      ).createShader(bounds),
                      child: Text(
                        _formatTime(_remainingSeconds),
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 80,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFF4A68E).withAlpha(80),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Motivational quote
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: Column(
                          key: ValueKey<int>(_quoteIndex),
                          children: [
                            Text(
                              '"${_quotes[_quoteIndex]['quote']}"',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 14,
                                color: Colors.white.withAlpha(180),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '- ${_quotes[_quoteIndex]['author']}',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 12,
                                color: Colors.white.withAlpha(130),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Pause / Play button with ripples when paused
                    AnimatedBuilder(
                      animation: Listenable.merge([_pulseAnimation, _rippleController]),
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: _sessionCompleted ? null : _togglePause,
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ripple rings (only when paused)
                                if (_isPaused)
                                  for (int i = 0; i < 3; i++)
                                    Builder(builder: (context) {
                                      final phase = (_rippleController.value + i / 3) % 1.0;
                                      final size = 80 + phase * 60;
                                      final opacity = (1.0 - phase) * 0.4;
                                      return Container(
                                        width: size,
                                        height: size,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFF4A68E).withAlpha((opacity * 255).toInt()),
                                            width: 1.5,
                                          ),
                                        ),
                                      );
                                    }),
                                // Main button
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFF4A68E),
                                        Color(0xFFE07A5F),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF4A68E).withAlpha(100),
                                        blurRadius: _isPaused ? 18 + _pulseAnimation.value : 18,
                                        spreadRadius: _isPaused ? 1 + _pulseAnimation.value * 0.4 : 1,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                    size: 56,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 2),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
