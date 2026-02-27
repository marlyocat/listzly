import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:listzly/pages/home_page.dart';
import 'package:listzly/theme/colors.dart';

class _TourCard {
  final String imagePath;
  final String title;
  final String description;
  const _TourCard({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class FeatureTourPage extends StatefulWidget {
  const FeatureTourPage({super.key});

  @override
  State<FeatureTourPage> createState() => _FeatureTourPageState();
}

class _FeatureTourPageState extends State<FeatureTourPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _cards = [
    _TourCard(
      imagePath: 'lib/images/onboarding_practice_sticker.png',
      title: 'Start Practicing',
      description:
          'Pick an instrument, set a timer, and begin a focused practice session. Piano is available on the free plan.',
    ),
    _TourCard(
      imagePath: 'lib/images/onboarding_target_sticker.png',
      title: 'Build Your Streak',
      description:
          'Practice every day to build your streak and stay consistent. Don\'t break the chain!',
    ),
    _TourCard(
      imagePath: 'lib/images/onboarding_quests_sticker.png',
      title: 'Complete Quests',
      description:
          'Take on daily and weekly quests to challenge yourself and earn XP as you improve.',
    ),
    _TourCard(
      imagePath: 'lib/images/onboarding_education_sticker.png',
      title: 'Learn Together',
      description:
          'Join your teacher\'s group with an invite code, or create your own group as a teacher to track student progress.',
    ),
    _TourCard(
      imagePath: 'lib/images/onboarding_gift_sticker.png',
      title: 'Unlock More with Pro',
      description:
          'Go Pro to unlock all instruments, record and share your practice sessions, view activity history, and more. Start with everything you need for free.',
    ),
  ];

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      (route) => false,
    );
  }

  void _nextPage() {
    if (_currentPage < _cards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: Column(
          children: [
            // Header: brand + skip
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Listzly',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _goToHome,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sticker image
                        Image.asset(
                          card.imagePath,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),

                        // Title
                        Text(
                          card.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            card.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkTextSecondary,
                              height: 1.5,
                            ),
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
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_cards.length, (i) {
                  final isActive = i == _currentPage;
                  final isPast = i < _currentPage;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? accentCoral
                          : isPast
                              ? accentCoral.withAlpha(100)
                              : Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Next / Let's Go button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    gradient: const LinearGradient(
                      colors: [accentCoral, accentCoralDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentCoral.withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: Text(
                      _currentPage < _cards.length - 1 ? 'Next' : 'Let\'s Go',
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
}
