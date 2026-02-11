import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late AnimationController _tapScaleController;
  late Animation<double> _tapScaleAnimation;
  late AnimationController _celebrationController;
  late AnimationController _sparkleController;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _summarySlideAnimation;
  late Animation<double> _summaryOpacityAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _buttonOpacityAnimation;

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
    _tapScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _tapScaleController, curve: Curves.easeInOut),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );
    _checkOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );
    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeIn),
      ),
    );
    _summarySlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.40, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _summaryOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.40, 0.65, curve: Curves.easeIn),
      ),
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.55, 0.80, curve: Curves.elasticOut),
      ),
    );
    _buttonOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.55, 0.70, curve: Curves.easeIn),
      ),
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
    HapticFeedback.mediumImpact();
    _tapScaleController.forward().then((_) => _tapScaleController.reverse());
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
    HapticFeedback.heavyImpact();
    _pulseController.stop();
    _rippleController.stop();
    _quoteTimer?.cancel();
    _celebrationController.forward();
    _sparkleController.repeat();
  }

  Future<bool> _onWillPop() async {
    if (_sessionCompleted) return true;

    _timer?.cancel();
    final wasPaused = _isPaused;
    setState(() => _isPaused = true);

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: primaryDarkest,
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
              style: TextStyle(color: accentCoral, fontSize: 16),
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
    _tapScaleController.dispose();
    _celebrationController.dispose();
    _sparkleController.dispose();
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
        backgroundColor: primaryDarkest,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: purpleGradientColors,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Timer view
                if (!_sessionCompleted)
                Column(
                  children: [
                    const Spacer(flex: 3),

                    // Large countdown timer
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [accentCoralLight, Color(0xFFF4A68E)],
                      ).createShader(bounds),
                      child: Text(
                        _formatTime(_remainingSeconds),
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 85,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              color: accentCoral.withAlpha(80),
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
                      animation: Listenable.merge([_pulseAnimation, _rippleController, _tapScaleAnimation]),
                      builder: (context, child) {
                        return GestureDetector(
                          onTap: _sessionCompleted ? null : _togglePause,
                          child: ScaleTransition(
                            scale: _tapScaleAnimation,
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
                                            color: accentCoral.withAlpha((opacity * 255).toInt()),
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
                                        accentCoralDark,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentCoral.withAlpha(100),
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
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 2),
                  ],
                ),

                // TODO: Remove — temporary button to test celebration view
                if (!_sessionCompleted)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: TextButton(
                      onPressed: () {
                        _timer?.cancel();
                        setState(() {
                          _remainingSeconds = 0;
                          _sessionCompleted = true;
                        });
                        _onSessionComplete();
                      },
                      child: Text(
                        'End Session',
                        style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
                      ),
                    ),
                  ),

                // Celebration view
                if (_sessionCompleted)
                  _buildCelebrationView(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationView() {
    return AnimatedBuilder(
      animation: Listenable.merge([_celebrationController, _sparkleController]),
      builder: (context, child) {
        return Column(
          children: [
            const Spacer(flex: 3),

            // Checkmark with sparkles
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sparkle particles
                  for (int i = 0; i < 8; i++)
                    Builder(builder: (context) {
                      final angle = (i / 8) * 2 * pi + _sparkleController.value * 2 * pi;
                      final radius = 70.0 + sin(_sparkleController.value * 2 * pi + i) * 15.0;
                      final sparkleOpacity =
                          (sin(_sparkleController.value * 2 * pi * 2 + i * 0.8) * 0.5 + 0.5) *
                          _checkOpacityAnimation.value;
                      return Transform.translate(
                        offset: Offset(cos(angle) * radius, sin(angle) * radius),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentCoral.withAlpha((sparkleOpacity * 200).toInt()),
                            boxShadow: [
                              BoxShadow(
                                color: accentCoral.withAlpha((sparkleOpacity * 100).toInt()),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  // Checkmark circle
                  Transform.scale(
                    scale: _checkScaleAnimation.value,
                    child: Opacity(
                      opacity: _checkOpacityAnimation.value.clamp(0.0, 1.0),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF4A68E), accentCoralDark],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentCoral.withAlpha(100),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // "Session Complete!" text
            Transform.translate(
              offset: Offset(0, _textSlideAnimation.value),
              child: Opacity(
                opacity: _textOpacityAnimation.value.clamp(0.0, 1.0),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [accentCoralLight, Color(0xFFF4A68E)],
                  ).createShader(bounds),
                  child: Text(
                    'Session Complete!',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 36,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: accentCoral.withAlpha(80),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary
            Transform.translate(
              offset: Offset(0, _summarySlideAnimation.value),
              child: Opacity(
                opacity: _summaryOpacityAnimation.value.clamp(0.0, 1.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.instrumentIcon, color: Colors.white.withAlpha(180), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.instrument,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.durationMinutes} minutes practiced',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 14,
                        color: Colors.white.withAlpha(130),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Done button
            Transform.scale(
              scale: _buttonScaleAnimation.value,
              child: Opacity(
                opacity: _buttonOpacityAnimation.value.clamp(0.0, 1.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    width: 200,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF4A68E), accentCoralDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentCoral.withAlpha(100),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Done',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),
          ],
        );
      },
    );
  }
}
