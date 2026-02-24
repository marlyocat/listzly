import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:listzly/models/practice_session.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/session_provider.dart';
import 'package:listzly/providers/assigned_quest_provider.dart';
import 'package:listzly/providers/quest_provider.dart';
import 'package:listzly/providers/stats_provider.dart';
import 'package:listzly/providers/instrument_provider.dart';
import 'package:listzly/providers/settings_provider.dart';
import 'package:listzly/providers/recording_provider.dart';
import 'package:listzly/providers/subscription_provider.dart';
import 'package:listzly/components/upgrade_prompt.dart';
import 'package:listzly/services/notification_service.dart';
import 'package:listzly/theme/colors.dart';

class PracticePage extends ConsumerStatefulWidget {
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
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage>
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

  static const _maxRecordingSeconds = 300; // 5 minutes

  late int _remainingSeconds;
  late final DateTime _sessionStartTime;
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

  // Recording state
  bool _isRecording = false;
  bool _hasRecordedToday = false;
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  DateTime? _recordingStartTime;
  int _recordingElapsedSeconds = 0;
  late AnimationController _recPulseController;

  // Pending recording (stopped but not yet saved)
  String? _pendingRecordingPath;
  int _pendingRecordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _sessionStartTime = DateTime.now();
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

    _recPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _startTimer();
    _startQuoteRotation();
    _checkTodayRecording();
  }

  Future<void> _checkTodayRecording() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final recordings = await ref
          .read(recordingServiceProvider)
          .getUserRecordings(user.id);
      final now = DateTime.now();
      final hasToday = recordings.any((r) =>
          r.createdAt.year == now.year &&
          r.createdAt.month == now.month &&
          r.createdAt.day == now.day);
      if (mounted) setState(() => _hasRecordedToday = hasToday);
    } catch (_) {}
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
        setState(() {
          _remainingSeconds--;
          // Track recording elapsed time
          if (_isRecording && _recordingStartTime != null) {
            _recordingElapsedSeconds++;
            if (_recordingElapsedSeconds >= _maxRecordingSeconds) {
              _stopRecording(showSnackBar: true);
            }
          }
        });
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
        if (_isRecording) _recorder.pause();
      } else {
        _pulseController.stop();
        _rippleController.stop();
        _startTimer();
        if (_isRecording) _recorder.resume();
      }
    });
  }

  // ---- Recording methods ----

  Future<void> _toggleRecording() async {
    // Gate recording behind Pro
    final tier = ref.read(effectiveSubscriptionTierProvider);
    if (!tier.canRecord) {
      showUpgradePrompt(context, feature: 'Practice recordings');
      return;
    }

    if (_isRecording) {
      await _stopRecording();
    } else {
      if (_hasRecordedToday) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only record once per day',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              backgroundColor: accentCoralDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Microphone permission is required to record',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF1E0E3D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 22050,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _recordingStartTime = DateTime.now();
        _recordingElapsedSeconds = 0;
      });
      _recPulseController.repeat(reverse: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not start recording',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF1E0E3D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording({bool showSnackBar = false}) async {
    final path = _recordingPath;
    final elapsed = _recordingElapsedSeconds;

    try {
      await _recorder.stop();
    } catch (_) {}
    _recPulseController.stop();
    setState(() {
      _isRecording = false;
      _recordingPath = null;
      _recordingElapsedSeconds = 0;
      _recordingStartTime = null;
      // Hold the recording for user to save or discard
      if (path != null && elapsed > 0) {
        _pendingRecordingPath = path;
        _pendingRecordingDuration = elapsed;
      }
    });

    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recording reached 5-minute limit',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1E0E3D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _discardRecording() {
    setState(() {
      _pendingRecordingPath = null;
      _pendingRecordingDuration = 0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recording discarded',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: accentCoralDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _uploadRecording(String localPath, int durationSeconds) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(recordingServiceProvider).uploadRecording(
            userId: user.id,
            sessionId: null,
            instrumentName: widget.instrument,
            durationSeconds: durationSeconds,
            localFilePath: localPath,
          );
      ref.invalidate(userRecordingsProvider);
      if (mounted) {
        setState(() => _hasRecordedToday = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recording saved',
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
              'Could not save recording',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF1E0E3D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onSessionComplete() async {
    HapticFeedback.heavyImpact();
    _pulseController.stop();
    _rippleController.stop();
    _quoteTimer?.cancel();
    // Stop active recording and hold as pending
    if (_isRecording) {
      final path = _recordingPath;
      final elapsed = _recordingElapsedSeconds;
      try { await _recorder.stop(); } catch (_) {}
      _recPulseController.stop();
      _isRecording = false;
      _recordingPath = null;
      _recordingElapsedSeconds = 0;
      _recordingStartTime = null;
      if (path != null && elapsed > 0) {
        _pendingRecordingPath = path;
        _pendingRecordingDuration = elapsed;
      }
    }
    // Auto-save any pending recording when session completes
    if (_pendingRecordingPath != null) {
      _uploadRecording(_pendingRecordingPath!, _pendingRecordingDuration);
      _pendingRecordingPath = null;
      _pendingRecordingDuration = 0;
    }
    _celebrationController.forward();
    _sparkleController.repeat();
    _saveSession();
  }

  Future<void> _saveSession() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Capture services and container before async gaps so they remain valid
    // even if the widget is disposed when the user navigates away.
    final container = ProviderScope.containerOf(context);
    final sessionService = ref.read(sessionServiceProvider);
    final questService = ref.read(questServiceProvider);
    final assignedQuestService = ref.read(assignedQuestServiceProvider);
    final statsService = ref.read(statsServiceProvider);
    final settingsService = ref.read(settingsServiceProvider);

    final totalSeconds = widget.durationMinutes * 60;
    final actualSeconds = totalSeconds - _remainingSeconds;

    final session = PracticeSession(
      userId: user.id,
      instrumentName: widget.instrument,
      durationSeconds: actualSeconds,
      targetSeconds: totalSeconds,
      startedAt: _sessionStartTime,
    );

    try {
      final savedSession = await sessionService.saveSession(session);

      // Update quest progress
      await questService.updateQuestProgressAfterSession(
          user.id, savedSession);

      // Update assigned quest progress (for students in a group)
      try {
        await assignedQuestService
            .updateAssignedQuestProgressAfterSession(user.id, savedSession);
      } catch (_) {
        // Non-critical: assigned quest update failure shouldn't block session save
      }

      // Recalculate stats (streak, XP)
      await statsService.recalculateStats(user.id);

      // Schedule streak warning notifications (respects user's reminder time)
      try {
        final settings = await settingsService.getSettings(user.id);
        await NotificationService.instance.scheduleStreakWarnings(settings.reminderTime);
      } catch (_) {
        // Non-critical: streak warnings are a nice-to-have
      }

      // Invalidate providers so other pages see fresh data.
      // Uses container directly so this works even after widget disposal.
      container.invalidate(userStatsProvider);
      container.invalidate(dailyQuestsProvider);
      container.invalidate(weekCompletionStatusProvider);
      container.invalidate(assignedQuestProgressProvider);
      container.invalidate(assignedQuestDefinitionsProvider);
      container.invalidate(instrumentStatsProvider);
      container.invalidate(sessionListProvider);
      container.invalidate(weeklyBarDataProvider);
      container.invalidate(summaryStatsProvider);
    } catch (_) {
      // Session save failed silently — don't disrupt celebration UI
    }
  }

  Future<bool> _onWillPop() async {
    if (_sessionCompleted) return true;

    _timer?.cancel();
    final wasPaused = _isPaused;
    setState(() => _isPaused = true);
    if (_isRecording) _recorder.pause();

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
          style: TextStyle(color: darkTextSecondary, fontSize: 16),
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
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      // Discard active and pending recordings
      if (_isRecording) {
        try { await _recorder.stop(); } catch (_) {}
        _recPulseController.stop();
        _isRecording = false;
      }
      _recordingPath = null;
      _pendingRecordingPath = null;
      _pendingRecordingDuration = 0;
      return true;
    }

    // Resume if it wasn't paused before
    if (!wasPaused) {
      setState(() => _isPaused = false);
      _startTimer();
      if (_isRecording) _recorder.resume();
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
    _recPulseController.dispose();
    _recorder.dispose();
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
        backgroundColor: const Color(0xFF150833),
        body: SafeArea(
            child: Stack(
              children: [
                // Radial glow behind the timer
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accentCoral.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
                                color: darkTextSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '- ${_quotes[_quoteIndex]['author']}',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 12,
                                color: darkTextMuted,
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

                    const SizedBox(height: 16),

                    // Mic / Record button
                    _buildMicButton(),

                    const Spacer(flex: 2),
                  ],
                ),

                // Celebration view
                if (_sessionCompleted)
                  _buildCelebrationView(),

              ],
            ),
          ),
        ),
    );
  }

  Widget _buildMicButton() {
    // Show save/discard buttons when recording is pending
    if (_pendingRecordingPath != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 20, color: accentCoral),
          const SizedBox(height: 4),
          Text(
            'Recorded ${_formatTime(_pendingRecordingDuration)}',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: darkTextSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Complete the practice session to save the recording.\nExiting early will discard it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: darkTextMuted,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _discardRecording,
            child: Text(
              'Discard Recording',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.red,
                decoration: TextDecoration.underline,
                decorationColor: Colors.red,
              ),
            ),
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation: _recPulseController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: _hasRecordedToday && !_isRecording ? 0.4 : 1.0,
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? Colors.red.withAlpha(30)
                        : darkSurfaceBg,
                    border: Border.all(
                      color: _isRecording
                          ? Colors.red.withAlpha(
                              (100 + _recPulseController.value * 155).toInt())
                          : darkCardBorder,
                      width: _isRecording ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 22,
                    color: _isRecording ? Colors.red : darkTextSecondary,
                  ),
                ),
              ),
            ),
            if (_isRecording) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withAlpha(
                          (150 + _recPulseController.value * 105).toInt()),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'REC ${_formatTime(_recordingElapsedSeconds)} / 5:00',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade300,
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _hasRecordedToday ? 'Recorded today' : 'Record',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: darkTextMuted,
                  ),
                ),
              ),
          ],
        );
      },
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
                        Icon(widget.instrumentIcon, color: darkTextSecondary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.instrument,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            color: darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.durationMinutes} minutes practiced',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 14,
                        color: darkTextMuted,
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
