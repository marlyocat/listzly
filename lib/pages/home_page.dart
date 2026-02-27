import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:listzly/components/flip_box_nav_bar.dart';
import 'package:listzly/pages/quests_page.dart';
import 'package:listzly/pages/activity_page.dart';
import 'package:listzly/pages/profile_page.dart';
import 'package:listzly/pages/practice_page.dart';
import 'package:listzly/pages/students_page.dart';
import 'package:listzly/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listzly/providers/stats_provider.dart';
import 'package:listzly/providers/session_provider.dart';
import 'package:listzly/providers/settings_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/subscription_provider.dart';
import 'package:listzly/components/upgrade_prompt.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher =
        ref.watch(currentProfileProvider).value?.isTeacher ?? false;

    final pages = <Widget>[
      const _HomeTab(),
      const QuestsPage(),
      const ActivityPage(),
      if (isTeacher) const StudentsPage(),
      const ProfilePage(),
    ];

    final navItems = <FlipBoxNavItem>[
      FlipBoxNavItem(
        name: 'Home',
        selectedImage: 'lib/images/home_selected.png',
        unselectedImage: 'lib/images/home_unselected.png',
        selectedBackgroundColor: primaryColor,
        unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
      ),
      FlipBoxNavItem(
        name: 'Quests',
        selectedImage: 'lib/images/quest_selected.png',
        unselectedImage: 'lib/images/quest_unselected.png',
        selectedBackgroundColor: primaryColor,
        unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
      ),
      FlipBoxNavItem(
        name: 'Activity',
        selectedImage: 'lib/images/trophy_selected.png',
        unselectedImage: 'lib/images/trophy_unselected.png',
        selectedBackgroundColor: primaryColor,
        unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
      ),
      if (isTeacher)
        FlipBoxNavItem(
          name: 'Students',
          selectedImage: 'lib/images/students_selected.png',
          unselectedImage: 'lib/images/students_unselected.png',
          selectedBackgroundColor: primaryColor,
          unselectedBackgroundColor: primaryColor.withValues(alpha: 0.6),
        ),
      FlipBoxNavItem(
        name: 'Profile',
        selectedImage: 'lib/images/settings_selected.png',
        unselectedImage: 'lib/images/settings_unselected.png',
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
        child: FlipBoxNavBar(
          currentIndex: safeIndex,
          onTap: _onItemTapped,
          items: navItems,
        ),
      ),
    );
  }
}

class _InstrumentData {
  final String name;
  final IconData icon;
  final String? imagePath;
  final List<Map<String, String>> quotes;
  const _InstrumentData({required this.name, required this.icon, this.imagePath, required this.quotes});
}

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double? _selectedDuration;
  int? _lastKnownGoal;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rippleController;

  late List<int> _quoteIndices;

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
  }

  static const List<_InstrumentData> _instruments = [
    _InstrumentData(name: 'Piano', icon: Icons.piano, imagePath: 'lib/images/piano_sticker.png', quotes: [
      {'quote': 'Simplicity is the final achievement.', 'author': 'Frederic Chopin'},
      {'quote': 'There is no such thing as a difficult piece. It is either impossible or it is easy.', 'author': 'Sergei Rachmaninoff'},
      {'quote': 'To play a wrong note is insignificant; to play without passion is inexcusable.', 'author': 'Ludwig van Beethoven'},
      {'quote': 'The piano is the silence between the notes.', 'author': 'Claude Debussy'},
      {'quote': 'The piano is a beautiful instrument to express the deepest feelings of the soul.', 'author': 'Franz Liszt'},
      {'quote': 'Beware of missing chances; otherwise it may be altogether too late some day.', 'author': 'Franz Liszt'},
    ]),
    _InstrumentData(name: 'Guitar', icon: Icons.music_note, imagePath: 'lib/images/guitar_sticker.png', quotes: [
      {'quote': 'The guitar is a small orchestra.', 'author': 'Andres Segovia'},
      {'quote': 'The guitar chose me, and I gave my life to it.', 'author': 'Paco de Lucia'},
      {'quote': 'A guitar is more than just a sound box. It is part of your soul.', 'author': 'Manuel Barrueco'},
      {'quote': 'The guitar has a kind of grit and excitement possessed by nothing else.', 'author': 'Brian May'},
      {'quote': 'My guitar is not a thing. It is an extension of myself. It is who I am.', 'author': 'Willie Nelson'},
    ]),
    _InstrumentData(name: 'Violin', icon: Icons.music_note_outlined, imagePath: 'lib/images/violin_sticker.png', quotes: [
      {'quote': 'The violin can be the most beautiful voice in the world.', 'author': 'Niccolo Paganini'},
      {'quote': 'A violin sings from the depths of the human soul.', 'author': 'Itzhak Perlman'},
      {'quote': 'The violin is the perfect instrument of the heart.', 'author': 'Antonio Vivaldi'},
      {'quote': 'Every difficulty I have ever faced playing the violin has been overcome by practice.', 'author': 'Jascha Heifetz'},
      {'quote': 'Practicing is not about being perfect. It is about getting better every day.', 'author': 'Hilary Hahn'},
    ]),
    _InstrumentData(name: 'Drums', icon: Icons.surround_sound, imagePath: 'lib/images/drum-set_sticker.png', quotes: [
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
    _rippleController.dispose();
    super.dispose();
  }

  void _onGoTap() {
    final tier = ref.read(effectiveSubscriptionTierProvider);
    if (!tier.canUseAllInstruments && _currentPage != 0) {
      showUpgradePrompt(context, feature: 'All instruments');
      return;
    }

    final instrument = _instruments[_currentPage];
    Navigator.push(
      context,
      PageRouteBuilder(
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => PracticePage(
          instrument: instrument.name,
          instrumentIcon: instrument.icon,
          durationMinutes: (_selectedDuration ?? 15).toInt(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userStatsProvider);
    final streakDays = statsAsync.value?.currentStreak ?? 0;
    final longestStreak = statsAsync.value?.longestStreak ?? 0;
    final streakBroken = streakDays == 0 && longestStreak > 0;

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
      if (_selectedDuration == null || _lastKnownGoal != goalMinutes) {
        final practicedMinutes = todayStats.totalTime.inMinutes;
        final remaining = goalMinutes - practicedMinutes;
        // Round up to nearest 5, clamp to slider range (5–120), default to 15 if goal met
        _selectedDuration = remaining > 0
            ? ((remaining / 5).ceil() * 5).toDouble().clamp(5, 120)
            : 15;
        _lastKnownGoal = goalMinutes;
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
            SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Streak badge
              Container(
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
                    Image.asset('lib/images/streak.png',
                        width: 18, height: 18),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$streakDays day streak',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (streakBroken)
                          Text(
                            'Streak Broken',
                            style: GoogleFonts.nunito(
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

              const SizedBox(height: 8),

              // Swipeable instrument carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _instruments.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final inst = _instruments[index];
                    final tier = ref.watch(effectiveSubscriptionTierProvider);
                    final isLocked = !tier.canUseAllInstruments && index != 0;
                    return Column(
                        children: [
                          if (inst.imagePath != null)
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Opacity(
                                    opacity: isLocked ? 0.4 : 1.0,
                                    child: Image.asset(
                                      inst.imagePath!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  if (isLocked)
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withAlpha(120),
                                      ),
                                      child: const Icon(
                                        Icons.lock_rounded,
                                        size: 28,
                                        color: Colors.white70,
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            Expanded(
                              child: Icon(inst.icon, size: 200, color: Colors.white.withAlpha(isLocked ? 60 : 180)),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 48),
                              Expanded(
                                child: Column(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [Colors.white, accentCoral],
                                      ).createShader(bounds),
                                      child: Text(
                                        inst.name,
                                        style: GoogleFonts.dmSerifDisplay(
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
                                        style: GoogleFonts.dmSerifDisplay(
                                          fontSize: 14,
                                          color: darkTextSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '- ${inst.quotes[_quoteIndices[index]]['author']}',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 12,
                                        color: darkTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Vertical duration slider
                              SizedBox(
                                width: 48,
                                height: 160,
                                child: Column(
                                  children: [
                                    Text(
                                      '${(_selectedDuration ?? 15).toInt()}',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 16,
                                        color: accentCoral,
                                      ),
                                    ),
                                    Text(
                                      'min',
                                      style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: darkTextMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                          ),
                                          child: Slider(
                                            value: _selectedDuration ?? 15,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_pulseAnimation, _rippleController]),
                  builder: (context, child) {
                    return GestureDetector(
                      onTap: _onGoTap,
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ripple rings
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
                              width: 80,
                              height: 80,
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
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
          ],
        ),
    );
  }
}
