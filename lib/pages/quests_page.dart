import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE8EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Quests', style: TextStyle(color: Colors.grey[900])),
      ),
      body: Center(
        child: Text(
          'Quests',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            color: Colors.grey[900],
          ),
        ),
      ),
    );
  }
}
