import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Activity', style: TextStyle(color: Colors.grey[900])),
      ),
      body: Center(
        child: Text(
          'Activity',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            color: Colors.grey[900],
          ),
        ),
      ),
    );
  }
}
