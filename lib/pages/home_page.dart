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

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  void _onGoTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PracticePage(
          instrument: 'Piano',
          instrumentIcon: Icons.piano,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    // Title
                    Text(
                      'Practice',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Central area with large Lottie animation
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'lib/images/playing_piano.json',
                        width: 300,
                        height: 300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Piano',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom bar with Go button
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 40),

                    // Go button
                    GestureDetector(
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

                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
