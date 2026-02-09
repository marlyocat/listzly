import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: Colors.grey[900])),
      ),
      body: Center(
        child: Text(
          'Profile',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            color: Colors.grey[900],
          ),
        ),
      ),
    );
  }
}
