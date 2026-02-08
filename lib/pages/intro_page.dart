import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/components/button.dart';
import 'package:listzly/theme/colors.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 25),

            Text(
              "Music Man",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 28,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Image.asset('lib/images/music_instrument.png', height: 200,),
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
              style: TextStyle(
                color: Colors.grey[300],
                height: 2,
              ),
            ),

            const SizedBox(height: 10),

            MyButton(
              text: "Get Started",
              onTap: () {
                // Go to Home Page
                Navigator.pushNamed(context, '/homepage');
              }
            )

          ],
        )
      )
    );
  }
}