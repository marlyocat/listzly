import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:listzly/components/flip_box_nav_bar.dart';
import 'package:listzly/pages/quests_page.dart';
import 'package:listzly/pages/activity_page.dart';
import 'package:listzly/pages/profile_page.dart';
import 'package:listzly/pages/practice_page.dart';
import 'package:listzly/theme/colors.dart';

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
  const _InstrumentData({required this.name, required this.icon, this.lottiePath});
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_InstrumentData> _instruments = [
    _InstrumentData(name: 'Piano', icon: Icons.piano, lottiePath: 'lib/images/playing_piano.json'),
    _InstrumentData(name: 'Guitar', icon: Icons.music_note, lottiePath: 'lib/images/playing_guitar.json'),
    _InstrumentData(name: 'Violin', icon: Icons.music_note_outlined, lottiePath: 'lib/images/playing_violin.json'),
    _InstrumentData(name: 'Drums', icon: Icons.surround_sound, lottiePath: 'lib/images/playing_drums.json'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onGoTap() {
    final instrument = _instruments[_currentPage];
    Navigator.push(
      context,
      MaterialPageRoute(
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryColor.withAlpha(200),
              const Color(0xFF4A1D8E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Center(
                  child: Text(
                    'Practice',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Swipeable instrument carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _instruments.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final inst = _instruments[index];
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (inst.lottiePath != null)
                            Lottie.asset(
                              inst.lottiePath!,
                              width: 300,
                              height: 300,
                            )
                          else
                            Icon(inst.icon, size: 200, color: Colors.white.withAlpha(180)),
                          const SizedBox(height: 16),
                          Text(
                            inst.name,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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

              // Go button
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: GestureDetector(
                  onTap: _onGoTap,
                  child: Container(
                    width: 140,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'Go',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
