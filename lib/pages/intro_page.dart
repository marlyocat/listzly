import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:listzly/components/button.dart';
import 'package:listzly/pages/auth_page.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/responsive.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoAnim;
  late final Animation<double> _imageAnim;
  late final Animation<double> _line1Anim;
  late final List<Animation<double>> _practiceLetterAnims;
  late final Animation<double> _line3Anim;
  late final Animation<double> _subtitleAnim;
  late final Animation<double> _buttonAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // 1. Image scales in
    _imageAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
    );
    // 2. "YOUR MUSIC" slides from left
    _line1Anim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.28, curve: Curves.easeOut),
    );
    // 3. "COMPANION" slides from right
    _line3Anim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.38, curve: Curves.easeOut),
    );
    // 4. "PRACTICE" letters drop/bounce in
    const practiceLetters = 'PRACTICE';
    _practiceLetterAnims = List.generate(practiceLetters.length, (i) {
      final start = 0.35 + (i * 0.025);
      final end = (start + 0.12).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
    // 5. "Listzly" logo slides up
    _logoAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.7, curve: Curves.easeOut),
    );
    // 6. Subtitle drops/bounces in
    _subtitleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.82, curve: Curves.easeOut),
    );
    // 7. Button slides up
    _buttonAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _slideUp(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - anim.value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _slideLeft(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(-30 * (1 - anim.value), 0),
            child: child,
          ),
        );
      },
    );
  }

  Widget _slideRight(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(30 * (1 - anim.value), 0),
            child: child,
          ),
        );
      },
    );
  }

  Widget _scaleIn(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(
            scale: 0.6 + (0.4 * anim.value),
            child: child,
          ),
        );
      },
    );
  }

  Widget _dropBounce(Animation<double> anim, Widget child) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final bounce = anim.value < 0.7
            ? anim.value / 0.7
            : 1.0 + 0.1 * math.sin((anim.value - 0.7) / 0.3 * math.pi);
        return Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -30 * (1 - bounce)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: GestureDetector(
        onTap: () {
          if (_controller.isAnimating) {
            _controller.forward(from: 1.0);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Subtle radial glow behind the image area
            Positioned(
              top: screenHeight * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentCoral.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: ContentConstraint(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Logo / brand name
                    _slideUp(
                      _logoAnim,
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, accentCoral],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          "Listzly",
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Image — scales in like a note being struck
                    _scaleIn(
                      _imageAnim,
                      Center(
                        child: Transform.translate(
                          offset: const Offset(0, 30),
                          child: SvgPicture.asset(
                            'lib/images/licensed/svg/music-instrument.svg',
                            height: 220,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Headline — staggered with varied animations
                    _slideLeft(
                      _line1Anim,
                      Text(
                        'YOUR MUSIC',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 42,
                          color: Colors.white,
                          height: 1.05,
                        ),
                      ),
                    ),
                    Row(
                      children: 'PRACTICE'.split('').asMap().entries.map((e) {
                        return _dropBounce(
                          _practiceLetterAnims[e.key],
                          Text(
                            e.value,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 42,
                              color: accentCoral,
                              height: 1.05,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    _slideRight(
                      _line3Anim,
                      Text(
                        'COMPANION',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 42,
                          color: Colors.white,
                          height: 1.05,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle with a left accent bar
                    _scaleIn(
                      _subtitleAnim,
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [accentCoral, accentCoralDark],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Set goals, build streaks, and\nmaster your instrument",
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: darkTextSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // CTA button
                    _slideUp(
                      _buttonAnim,
                      MyButton(
                        text: "Get Started",
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 800),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AuthPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                if (animation.status == AnimationStatus.reverse) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
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
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
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
