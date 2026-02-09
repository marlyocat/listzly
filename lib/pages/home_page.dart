import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/components/flip_box_nav_bar.dart';
import 'package:listzly/components/button.dart';
import 'package:listzly/pages/quests_page.dart';
import 'package:listzly/pages/activity_page.dart';
import 'package:listzly/pages/profile_page.dart';
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
              selectedBackgroundColor: const Color(0xFF4ECDC4),
              unselectedBackgroundColor: const Color(0xFF4ECDC4).withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Tokyo', style: TextStyle(color: Colors.grey[900])),
      ),
      body: Column(
        children: [
          // Promo Banner
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    //Promo Message
                    Text(
                      'Get 32% off',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Redeem Button
                    MyButton(text: "Redeem", onTap: () {}),
                  ],
                ),

                Image.asset('lib/images/music_instrument.png', height: 100),
              ],
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
