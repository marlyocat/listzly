import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class PracticePage extends StatelessWidget {
  final String instrument;
  final IconData instrumentIcon;

  const PracticePage({
    super.key,
    required this.instrument,
    required this.instrumentIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF9333EA),
              primaryColor,
              const Color(0xFF4A1D8E),
              const Color(0xFF2D1066),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          instrument,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Large metric display
              const Spacer(),
              Text(
                '0:00',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 72,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'duration',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 24),

              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == 0
                          ? Colors.white
                          : Colors.white.withAlpha(80),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Pause button
              Icon(instrumentIcon, size: 64, color: Colors.white.withAlpha(180)),

              const SizedBox(height: 16),

              Text(
                'Practice session coming soon!',
                style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 14),
              ),

              const Spacer(),

              // Cancel button
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 140,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
