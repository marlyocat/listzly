import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/components/button.dart';
import 'package:listzly/theme/colors.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: Stack(
          children: [
            // Background decorative rings
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                    width: 1,
                  ),
                ),
              ),
            ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Logo / brand name
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, accentCoral],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        "Music Man",
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Image — overlaps into the text area below
                    Center(
                      child: Transform.translate(
                        offset: const Offset(0, 30),
                        child: Image.asset(
                          'lib/images/music_instrument.png',
                          height: 220,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Headline — overlapped by the image above
                    Text(
                      "THE SOUND\nOF MUSICAL\nINSTRUMENTS",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 42,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle with a left accent bar
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
                            "Feel the sound of the most\nexciting instrument",
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

                    const Spacer(flex: 1),

                    // CTA button
                    MyButton(
                      text: "Get Started",
                      onTap: () {
                        Navigator.pushNamed(context, '/homepage');
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
