import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:listzly/components/flip_box_nav_bar.dart';
import 'package:listzly/pages/quests_page.dart';
import 'package:listzly/pages/activity_page.dart';
import 'package:listzly/pages/profile_page.dart';
import 'package:listzly/pages/practice_page.dart';
import 'package:listzly/theme/colors.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    QuestsPage(),
    ActivityPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        child: FlipBoxNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            FlipBoxNavItem(
              name: 'Home',
              selectedImage: 'lib/images/home_selected.png',
              unselectedImage: 'lib/images/home_unselected.png',
              selectedBackgroundColor: primaryColor,
              unselectedBackgroundColor: primaryColor.withOpacity(0.6),
            ),
            FlipBoxNavItem(
              name: 'Quests',
              selectedImage: 'lib/images/quest_selected.png',
              unselectedImage: 'lib/images/quest_unselected.png',
              selectedBackgroundColor: secondaryColor,
              unselectedBackgroundColor: secondaryColor.withOpacity(0.6),
            ),
            FlipBoxNavItem(
              name: 'Activity',
              selectedImage: 'lib/images/trophy_selected.png',
              unselectedImage: 'lib/images/trophy_unselected.png',
              selectedBackgroundColor: accentColor,
              unselectedBackgroundColor: accentColor.withOpacity(0.6),
            ),
            FlipBoxNavItem(
              name: 'Profile',
              selectedImage: 'lib/images/settings_selected.png',
              unselectedImage: 'lib/images/settings_unselected.png',
              selectedBackgroundColor: tealColor,
              unselectedBackgroundColor: tealColor.withOpacity(0.6),
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
  final String? lottiePath;
  final List<Map<String, String>> quotes;
  const _InstrumentData({required this.name, required this.icon, this.lottiePath, required this.quotes});
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
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
    _InstrumentData(name: 'Piano', icon: Icons.piano, lottiePath: 'lib/images/playing_piano.json', quotes: [
      {'quote': 'Simplicity is the final achievement.', 'author': 'Frederic Chopin'},
      {'quote': 'The piano keys are black and white, but they sound like a million colours in your mind.', 'author': 'Maria Cristina Mena'},
      {'quote': 'The piano is able to communicate the subtlest universal truths.', 'author': 'Vladimir Horowitz'},
      {'quote': 'The piano is the silence between the notes.', 'author': 'Claude Debussy'},
      {'quote': 'The piano is a beautiful instrument to express the deepest feelings of the soul.', 'author': 'Franz Liszt'},
      {'quote': 'Beware of missing chances; otherwise it may be altogether too late some day.', 'author': 'Franz Liszt'},
    ]),
    _InstrumentData(name: 'Guitar', icon: Icons.music_note, lottiePath: 'lib/images/playing_guitar.json', quotes: [
      {'quote': 'The guitar is a small orchestra.', 'author': 'Andres Segovia'},
      {'quote': 'The guitar chose me, and I gave my life to it.', 'author': 'Paco de Lucia'},
      {'quote': 'A guitar is more than just a sound box. It is part of your soul.', 'author': 'Manuel Barrueco'},
      {'quote': 'The tone of the guitar is between a flute and a harp.', 'author': 'Fernando Sor'},
      {'quote': 'Music embodies feeling without forcing it to contend with thought.', 'author': 'Franz Liszt'},
    ]),
    _InstrumentData(name: 'Violin', icon: Icons.music_note_outlined, lottiePath: 'lib/images/playing_violin.json', quotes: [
      {'quote': 'The violin can be the most beautiful voice in the world.', 'author': 'Niccolo Paganini'},
      {'quote': 'A violin sings from the depths of the human soul.', 'author': 'Itzhak Perlman'},
      {'quote': 'The violin is the perfect instrument of the heart.', 'author': 'Antonio Vivaldi'},
      {'quote': 'When words leave off, the violin begins.', 'author': 'Heinrich Heine'},
      {'quote': 'Inspiration is enough to give expression to the tone in singing, especially when the song is without words.', 'author': 'Franz Liszt'},
    ]),
    _InstrumentData(name: 'Drums', icon: Icons.surround_sound, lottiePath: 'lib/images/playing_drums.json', quotes: [
      {'quote': 'The drummer drives. Everyone else rides.', 'author': 'Buddy Rich'},
      {'quote': 'A good drummer listens as much as he plays.', 'author': 'Indian Proverb'},
      {'quote': 'Drums are the heartbeat of music.', 'author': 'Ringo Starr'},
      {'quote': 'Rhythm is the soul of life. The whole universe revolves in rhythm.', 'author': 'Babatunde Olatunji'},
      {'quote': 'Music is the heart of life. Without it, there is no possible good and with it everything is beautiful.', 'author': 'Franz Liszt'},
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
    final instrument = _instruments[_currentPage];
    Navigator.push(
      context,
      TurnPageRoute(
        overleafColor: const Color(0xFF4A1D8E),
        animationTransitionPoint: 0.5,
        transitionDuration: const Duration(milliseconds: 600),
        builder: (context) => PracticePage(
          instrument: instrument.name,
          instrumentIcon: instrument.icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
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
                          if (inst.lottiePath != null)
                            Expanded(
                              child: Lottie.asset(
                                inst.lottiePath!,
                                fit: BoxFit.contain,
                              ),
                            )
                          else
                            Expanded(
                              child: Icon(inst.icon, size: 200, color: Colors.white.withAlpha(180)),
                            ),
                          const SizedBox(height: 16),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFF4A68E)],
                            ).createShader(bounds),
                            child: Text(
                              inst.name,
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 32,
                                color: Colors.white,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFF4A68E).withAlpha(80),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              '"${inst.quotes[_quoteIndices[index]]['quote']}"',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 14,
                                color: Colors.white.withAlpha(180),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '- ${inst.quotes[_quoteIndices[index]]['author']}',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 12,
                              color: Colors.white.withAlpha(130),
                            ),
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
                        color: isActive ? Colors.white : Colors.white.withAlpha(80),
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
                                      color: const Color(0xFFF4A68E).withAlpha((opacity * 255).toInt()),
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
                                    Color(0xFFF4A68E),
                                    Color(0xFFE07A5F),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF4A68E).withAlpha(100),
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
      ),
    );
  }
}
