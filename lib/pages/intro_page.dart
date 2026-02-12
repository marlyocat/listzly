import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/components/button.dart';
import 'package:listzly/theme/colors.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkest,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: purpleGradientColors,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 25),

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

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image.asset('lib/images/music_instrument.png', height: 200),
              ),

              Text(
                "THE SOUND OF MUSICAL INSTRUMENTS",
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 44,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Feel the sound of the most exciting instrument",
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: darkTextSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 10),

              MyButton(
                text: "Get Started",
                onTap: () {
                  Navigator.pushNamed(context, '/homepage');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
