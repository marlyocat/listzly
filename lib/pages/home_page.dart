import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import 'package:listzly/components/skeleton_loader.dart';
import 'package:listzly/components/flip_box_nav_bar.dart';
import 'package:listzly/pages/quests_page.dart';
import 'package:listzly/pages/activity_page.dart';
import 'package:listzly/pages/profile_page.dart';
import 'package:listzly/pages/practice_page.dart';
import 'package:listzly/pages/students_page.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/responsive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listzly/providers/nav_provider.dart';
import 'package:listzly/providers/stats_provider.dart';
import 'package:listzly/providers/session_provider.dart';
import 'package:listzly/providers/settings_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/components/animated_seal_tooltip.dart';
import 'package:listzly/components/now_playing_banner.dart';
import 'package:listzly/providers/music_provider.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    ref.read(navIndexProvider.notifier).set(index);
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher =
        ref.watch(currentProfileProvider).value?.isTeacher ?? false;

    final pages = <Widget>[
      ShowCaseWidget(
        builder: (context) => const _HomeTab(),
      ),
      ShowCaseWidget(
        enableAutoScroll: true,
        builder: (context) => const QuestsPage(),
      ),
      ShowCaseWidget(
        enableAutoScroll: true,
        builder: (context) => const ActivityPage(),
      ),
      if (isTeacher) ShowCaseWidget(
        enableAutoScroll: true,
        builder: (context) => const StudentsPage(),
      ),
      ShowCaseWidget(
        enableAutoScroll: true,
        builder: (context) => const ProfilePage(),
      ),
    ];

    final navItems = <FlipBoxNavItem>[
      FlipBoxNavItem(
        name: 'Home',
        selectedImage: 'lib/images/licensed/svg/home-selected.svg',
        unselectedImage: 'lib/images/licensed/svg/home-unselected.svg',
        selectedBackgroundColor: primaryColor,
        unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
      ),
      FlipBoxNavItem(
        name: 'Quests',
        selectedImage: 'lib/images/licensed/svg/quest-selected.svg',
        unselectedImage: 'lib/images/licensed/svg/quest-unselected.svg',
        selectedBackgroundColor: primaryColor,
        unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
      ),
      FlipBoxNavItem(
        name: 'Activity',
        selectedImage: 'lib/images/licensed/svg/trophy-selected.svg',
        unselectedImage: 'lib/images/licensed/svg/trophy-unselected.svg',
        selectedBackgroundColor: primaryColor,
        unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
      ),
      if (isTeacher)
        FlipBoxNavItem(
          name: 'Students',
          selectedImage: 'lib/images/licensed/svg/students-selected.svg',
          unselectedImage: 'lib/images/licensed/svg/students-unselected.svg',
          selectedBackgroundColor: primaryColor,
          unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
        ),
      FlipBoxNavItem(
        name: 'Profile',
        selectedImage: 'lib/images/licensed/svg/settings-selected.svg',
        unselectedImage: 'lib/images/licensed/svg/settings-unselected.svg',
        selectedBackgroundColor: primaryColor,
        unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
      ),
    ];

    // Clamp index to prevent overflow when switching roles
    final safeIndex = _selectedIndex.clamp(0, pages.length - 1);

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (safeIndex == 0) const NowPlayingBanner(),
            FlipBoxNavBar(
              currentIndex: safeIndex,
              onTap: _onItemTapped,
              items: navItems,
            ),
          ],
        ),
      ),
    );
  }
}

class _InstrumentData {
  final String name;
  final IconData icon;
  final String? imagePath;
  final String? iconPath;
  final List<Map<String, String>> quotes;
  const _InstrumentData({required this.name, required this.icon, this.imagePath, this.iconPath, required this.quotes});
}

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _selectedDuration = prefsInstance.getDouble('cached_duration') ?? 15;
  int? _lastKnownGoal;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rippleController;
  late AnimationController _streakCountUpController;
  int? _lastStreakTarget;

  late List<int> _quoteIndices;

  // Showcase keys
  final _streakKey = GlobalKey();
  final _playKey = GlobalKey();

  void _startShowcase() {
    ShowcaseView.get().startShowCase([
      _streakKey,
      _playKey,
    ]);
  }

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _quoteIndices = List.generate(
      _instruments.length,
      (i) => rng.nextInt(_instruments[i].quotes.length),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
    _streakCountUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  static const List<_InstrumentData> _instruments = [
    _InstrumentData(name: 'Piano', icon: Icons.piano, imagePath: 'lib/images/licensed/svg/piano-sticker.svg', iconPath: 'lib/images/licensed/svg/piano.svg', quotes: [
      {'quote': 'Simplicity is the final achievement.', 'author': 'Frederic Chopin'},
      {'quote': 'There is no such thing as a difficult piece. It is either impossible or it is easy.', 'author': 'Sergei Rachmaninoff'},
      {'quote': 'To play a wrong note is insignificant; to play without passion is inexcusable.', 'author': 'Ludwig van Beethoven'},
      {'quote': 'The piano is the silence between the notes.', 'author': 'Claude Debussy'},
      {'quote': 'The piano is a beautiful instrument to express the deepest feelings of the soul.', 'author': 'Franz Liszt'},
      {'quote': 'Beware of missing chances; otherwise it may be altogether too late some day.', 'author': 'Franz Liszt'},
    ]),
    _InstrumentData(name: 'Guitar', icon: Icons.music_note, imagePath: 'lib/images/licensed/svg/guitar-sticker.svg', iconPath: 'lib/images/licensed/svg/guitar.svg', quotes: [
      {'quote': 'The guitar is a small orchestra.', 'author': 'Andres Segovia'},
      {'quote': 'The guitar chose me, and I gave my life to it.', 'author': 'Paco de Lucia'},
      {'quote': 'A guitar is more than just a sound box. It is part of your soul.', 'author': 'Manuel Barrueco'},
      {'quote': 'The guitar has a kind of grit and excitement possessed by nothing else.', 'author': 'Brian May'},
      {'quote': 'My guitar is not a thing. It is an extension of myself. It is who I am.', 'author': 'Willie Nelson'},
    ]),
    _InstrumentData(name: 'Violin', icon: Icons.music_note_outlined, imagePath: 'lib/images/licensed/svg/violin-sticker.svg', iconPath: 'lib/images/licensed/svg/violin.svg', quotes: [
      {'quote': 'The violin can be the most beautiful voice in the world.', 'author': 'Niccolo Paganini'},
      {'quote': 'A violin sings from the depths of the human soul.', 'author': 'Itzhak Perlman'},
      {'quote': 'The violin is the perfect instrument of the heart.', 'author': 'Antonio Vivaldi'},
      {'quote': 'Every difficulty I have ever faced playing the violin has been overcome by practice.', 'author': 'Jascha Heifetz'},
      {'quote': 'Practicing is not about being perfect. It is about getting better every day.', 'author': 'Hilary Hahn'},
    ]),
    _InstrumentData(name: 'Drums', icon: Icons.surround_sound, imagePath: 'lib/images/licensed/svg/drum-set-sticker.svg', iconPath: 'lib/images/licensed/svg/drums.svg', quotes: [
      {'quote': 'The drummer drives. Everyone else rides.', 'author': 'Buddy Rich'},
      {'quote': 'A great drummer is not just keeping time, he is making time.', 'author': 'Elvin Jones'},
      {'quote': 'Drums are the heartbeat of music.', 'author': 'Ringo Starr'},
      {'quote': 'Rhythm is the soul of life. The whole universe revolves in rhythm.', 'author': 'Babatunde Olatunji'},
      {'quote': 'A drummer is the conductor of the band.', 'author': 'Gene Krupa'},
    ]),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _streakCountUpController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _showStreakInfo(BuildContext context, int streakDays, bool streakBroken) async {
    final expiryTime = await ref.read(streakExpiryProvider.future);
    if (!mounted) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final practicedToday = expiryTime != null &&
        expiryTime.subtract(const Duration(days: 3)) == today;

    showDialog(
      context: context,
      builder: (ctx) => _StreakInfoDialog(
        streakDays: streakDays,
        streakBroken: streakBroken,
        practicedToday: practicedToday,
        expiryTime: expiryTime,
      ),
    );
  }

  void _onGoTap() {
    // Pause background music when starting practice
    ref.read(musicPlayerProvider).pauseForPractice();

    final instrument = _instruments[_currentPage];
    Navigator.push(
      context,
      PageRouteBuilder(
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => PracticePage(
          instrument: instrument.name,
          instrumentImagePath: instrument.iconPath,
          durationMinutes: _selectedDuration.toInt(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Only apply turn-page effect for forward animation
          if (animation.status == AnimationStatus.reverse) {
            return FadeTransition(opacity: animation, child: child);
          }
          return TurnPageTransition(
            animation: animation,
            overleafColor: primaryDark,
            animationTransitionPoint: 0.5,
            direction: TurnDirection.rightToLeft,
            child: child,
          );
        },
      ),
    ).then((_) {
      // Resume background music after practice ends
      ref.read(musicPlayerProvider).resumeAfterPractice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userStatsProvider);
    final streakDays = statsAsync.value?.currentStreak ?? 0;
    final longestStreak = statsAsync.value?.longestStreak ?? 0;
    final streakBroken = streakDays == 0 && longestStreak > 0;

    // Trigger count-up when streak data first arrives
    if (streakDays > 0 && _lastStreakTarget != streakDays) {
      _lastStreakTarget = streakDays;
      _streakCountUpController.forward(from: 0);
    }

    // Set slider to remaining daily goal on first load or when goal changes
    final settings = ref.watch(userSettingsProvider).value;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final todayStats = ref.watch(summaryStatsProvider(
      start: todayStart,
      end: todayEnd,
    )).value;

    if (settings != null && todayStats != null) {
      final goalMinutes = settings.dailyGoalMinutes;
      if (_lastKnownGoal != goalMinutes) {
        final practicedMinutes = todayStats.totalTime.inMinutes;
        final remaining = goalMinutes - practicedMinutes;
        // Round up to nearest 5, clamp to slider range (5–120), default to 15 if goal met
        _selectedDuration = remaining > 0
            ? ((remaining / 5).ceil() * 5).toDouble().clamp(5, 120)
            : 15;
        _lastKnownGoal = goalMinutes;
        prefsInstance.setDouble('cached_duration', _selectedDuration);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: Stack(
          children: [
            // Radial glow behind the play button area (bottom center)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentCoral.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Decorative ring top-left
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Bird tooltip
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: AnimatedSealTooltip(
                onTap: _startShowcase,
                navIndex: 0,
              ),
            ),
            SafeArea(
          child: ContentConstraint(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Streak badge
              Showcase(
                key: _streakKey,
                description: 'Track your daily practice streak here',
                tooltipBackgroundColor: const Color(0xFF1E0A4A),
                descTextStyle: TextStyle(fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.white,
                ),
                tooltipActions: [
                  TooltipActionButton(
                    type: TooltipDefaultActionType.skip,
                    name: 'Skip tour',
                    backgroundColor: Colors.red,
                    textStyle: TextStyle(fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
                child: statsAsync.isLoading
                    ? SkeletonShimmer(
                        child: SkeletonBox(
                          width: 140,
                          height: 32,
                          borderRadius: 20,
                        ),
                      )
                    : GestureDetector(
                  onTap: () => _showStreakInfo(context, streakDays, streakBroken),
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accentCoral.withAlpha(60),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: streakBroken
                            ? SvgPicture.asset(
                                'lib/images/licensed/svg/ice-cube.svg',
                                fit: BoxFit.contain,
                              )
                            : Lottie.asset(
                                'lib/images/licensed/json/fire-streak-animation.json',
                                fit: BoxFit.contain,
                              ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _streakCountUpController,
                            builder: (context, child) {
                              final value = (_streakCountUpController.value * streakDays).round();
                              return Text(
                                '$value day streak',
                                style: TextStyle(fontFamily: 'Nunito',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          if (streakBroken)
                            Text(
                              'Streak Broken',
                              style: TextStyle(fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentCoral,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
              ),

              const SizedBox(height: 8),

              // Swipeable instrument carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _instruments.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final inst = _instruments[index];
                    return Column(
                        children: [
                          if (inst.imagePath != null)
                            Expanded(
                              child: SvgPicture.asset(
                                inst.imagePath!,
                                fit: BoxFit.contain,
                              ),
                            )
                          else
                            Expanded(
                              child: Icon(inst.icon, size: 200, color: Colors.white.withAlpha(180)),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 40),
                              Expanded(
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [Colors.white, accentCoral],
                                      ).createShader(bounds),
                                      child: Text(
                                        inst.name,
                                        style: TextStyle(fontFamily: 'DM Serif Display',
                                          fontSize: 32,
                                          color: Colors.white,
                                          letterSpacing: 3,
                                          shadows: [
                                            Shadow(
                                              color: accentCoral.withAlpha(80),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        '"${inst.quotes[_quoteIndices[index]]['quote']}"',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontFamily: 'DM Serif Display',
                                          fontSize: 14,
                                          color: darkTextSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '- ${inst.quotes[_quoteIndices[index]]['author']}',
                                      style: TextStyle(fontFamily: 'DM Serif Display',
                                        fontSize: 12,
                                        color: darkTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // +/- buttons and vertical duration slider
                              SizedBox(
                                  width: 48,
                                  height: 190,
                                child: Column(
                                  children: [
                                    // Duration label
                                    Text(
                                      '${_selectedDuration.toInt()}',
                                      style: TextStyle(fontFamily: 'DM Serif Display',
                                        fontSize: 20,
                                        color: accentCoral,
                                      ),
                                    ),
                                    Text(
                                      'mins',
                                      style: TextStyle(fontFamily: 'Nunito',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: darkTextMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // + button
                                    GestureDetector(
                                      onTap: () {
                                        if (_selectedDuration < 120) {
                                          setState(() => _selectedDuration = _selectedDuration + 5);
                                        }
                                      },
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withAlpha(80),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    // Slider
                                    Expanded(
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 3,
                                            activeTrackColor: accentCoral,
                                            inactiveTrackColor: Colors.white.withAlpha(80),
                                            thumbColor: accentCoral,
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                            overlayColor: accentCoral.withAlpha(40),
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                                          ),
                                          child: Slider(
                                            value: _selectedDuration,
                                            min: 5,
                                            max: 120,
                                            divisions: 23,
                                            onChanged: (value) {
                                              setState(() => _selectedDuration = value);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    // - button
                                    GestureDetector(
                                      onTap: () {
                                        if (_selectedDuration > 5) {
                                          setState(() => _selectedDuration = _selectedDuration - 5);
                                        }
                                      },
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withAlpha(80),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.remove_rounded,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                    );
                  },
                ),
              ),

              // Dot indicators
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_instruments.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white.withAlpha(140),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),

              // Play button with ripples
              ValueListenableBuilder<int>(
              valueListenable: musicStateNotifier,
              builder: (context, _, __) {
              final hasMusicPlaying = ref.read(musicPlayerProvider).hasSong;
              final btnSize = hasMusicPlaying ? 64.0 : 80.0;
              final iconSize = hasMusicPlaying ? 38.0 : 48.0;
              final areaSize = hasMusicPlaying ? 110.0 : 140.0;
              final rippleBase = hasMusicPlaying ? 60.0 : 80.0;
              final rippleRange = hasMusicPlaying ? 50.0 : 60.0;
              return Showcase(
                key: _playKey,
                description: 'Tap to start your practice session!',
                tooltipBackgroundColor: const Color(0xFF1E0A4A),
                descTextStyle: TextStyle(fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnimatedBuilder(
                  animation: Listenable.merge([_pulseAnimation, _rippleController]),
                  builder: (context, child) {
                    return Semantics(
                      label: 'Start practice session',
                      button: true,
                      child: GestureDetector(
                      onTap: _onGoTap,
                      child: SizedBox(
                        width: areaSize,
                        height: areaSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ripple rings
                            for (int i = 0; i < 3; i++)
                              Builder(builder: (context) {
                                final phase = (_rippleController.value + i / 3) % 1.0;
                                final size = rippleBase + phase * rippleRange;
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
                              width: btnSize,
                              height: btnSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentCoral,
                                    accentCoralDark,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentCoral.withAlpha(100),
                                    blurRadius: 18 + _pulseAnimation.value,
                                    spreadRadius: 1 + _pulseAnimation.value * 0.4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: iconSize,
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
                ),
              );
              }),
            ],
          ),
        ),
        ),
          ],
        ),
    );
  }
}

class _StreakInfoDialog extends StatefulWidget {
  final int streakDays;
  final bool streakBroken;
  final bool practicedToday;
  final DateTime? expiryTime;

  const _StreakInfoDialog({
    required this.streakDays,
    required this.streakBroken,
    required this.practicedToday,
    required this.expiryTime,
  });

  @override
  State<_StreakInfoDialog> createState() => _StreakInfoDialogState();
}

class _StreakInfoDialogState extends State<_StreakInfoDialog> {
  late final Stream<Duration> _countdownStream;

  @override
  void initState() {
    super.initState();
    _countdownStream = Stream.periodic(const Duration(seconds: 1), (_) {
      if (widget.expiryTime == null) return Duration.zero;
      final remaining = widget.expiryTime!.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    });
  }

  String _formatCountdown(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final showCountdown = !widget.streakBroken &&
        widget.streakDays > 0 &&
        !widget.practicedToday &&
        widget.expiryTime != null;

    String message;
    if (widget.streakBroken) {
      message = 'Your streak was lost! Start practicing again to build a new one.';
    } else if (widget.streakDays == 0) {
      message = 'Start practicing to build your streak!';
    } else if (widget.practicedToday) {
      const messages = [
        'You practiced today! Keep it up!',
        'Great job today! Your dedication is paying off!',
        'Another day, another win! You\'re unstoppable!',
        'You showed up today! That\'s what champions do!',
        'Practice makes progress! Keep going!',
        'You\'re building something amazing, one day at a time!',
        'Consistency is key, and you\'ve got it!',
        'Today\'s practice is tomorrow\'s skill!',
        'You\'re on fire! Don\'t stop now!',
        'Music waits for no one, and neither do you!',
      ];
      message = messages[widget.streakDays % messages.length];
    } else {
      message = 'Practice now to keep your streak alive!';
    }

    return Dialog(
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
            SizedBox(
              width: 40,
              height: 40,
              child: widget.streakBroken
                  ? SvgPicture.asset(
                      'lib/images/licensed/svg/ice-cube.svg',
                      fit: BoxFit.contain,
                    )
                  : Lottie.asset(
                      'lib/images/licensed/json/fire-streak-animation.json',
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.streakBroken ? 'Streak Lost' : '${widget.streakDays} Day Streak',
              style: TextStyle(fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkTextSecondary,
              ),
            ),
            if (showCountdown) ...[
              const SizedBox(height: 16),
              StreamBuilder<Duration>(
                stream: _countdownStream,
                builder: (context, snapshot) {
                  final remaining = snapshot.data ??
                      widget.expiryTime!.difference(DateTime.now());
                  return Column(
                    children: [
                      Text(
                        'Streak expires in',
                        style: TextStyle(fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: darkTextMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCountdown(remaining.isNegative ? Duration.zero : remaining),
                        style: TextStyle(fontFamily: 'Nunito',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: accentCoral,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                widget.practicedToday || widget.streakDays == 0
                    ? 'OK'
                    : 'Practice Now',
                style: TextStyle(fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: accentCoral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
