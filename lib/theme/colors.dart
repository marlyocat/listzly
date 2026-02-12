import 'package:flutter/material.dart';

// Purple family
const primaryColor   = Color(0xFF7C3AED); // Deep Violet
const primaryLight   = Color(0xFF9333EA); // Light Violet
const primaryDark    = Color(0xFF4A1D8E); // Dark Violet
const primaryDarkest = Color(0xFF2D1066); // Deepest Violet

// Coral accent family
const accentCoral      = Color(0xFFF4A68E); // Coral
const accentCoralDark  = Color(0xFFE07A5F); // Dark Coral
const accentCoralLight = Color(0xFFFCE4DC); // Light Coral (badge bg)

// Neutrals
const neutralDark     = Color(0xFF3C3C3C);
const neutralMid      = Color(0xFFAFAFAF);
const neutralLight    = Color(0xFFE5E5E5);
const neutralLightest = Color(0xFFF0F0F0);

// Dark theme UI colors (for content on purple gradient backgrounds)
const darkCardBg = Color(0x33FFFFFF);        // white @ 51 alpha — card backgrounds
const darkCardBorder = Color(0x40FFFFFF);    // white @ 64 alpha — card borders
const darkTextSecondary = Color(0xF0FFFFFF); // white @ 240 alpha
const darkTextMuted = Color(0xD9FFFFFF);     // white @ 217 alpha
const darkDivider = Color(0x26FFFFFF);       // white @ 38 alpha
const darkSurfaceBg = Color(0x3DFFFFFF);     // white @ 61 alpha — icon/chip containers
const darkProgressBg = Color(0x33FFFFFF);    // white @ 51 alpha — progress bar tracks

// Hero card — elevated treatment for primary content cards
const heroCardBg = Color(0x40FFFFFF);        // white @ 64 alpha — stronger than darkCardBg
const heroCardBorder = Color(0x55FFFFFF);    // white @ 85 alpha — more visible border

// Standard purple gradient (home + practice)
const purpleGradientColors = [
  primaryLight,   // 0xFF9333EA
  primaryColor,   // 0xFF7C3AED
  primaryDark,    // 0xFF4A1D8E
  primaryDarkest, // 0xFF2D1066
];

// Per-page gradient variations — same family, subtle shifts
// Quests: warmer undertone (hint of amber/coral in the mid-tones)
const questsGradientColors = [
  Color(0xFF9B33EA), // warmer violet
  Color(0xFF7C3AED),
  Color(0xFF5A1D7E), // slightly warmer dark
  Color(0xFF2D1066),
];

// Activity: cooler undertone (hint of indigo/blue)
const activityGradientColors = [
  Color(0xFF7B33EA), // cooler violet
  Color(0xFF6D3AED),
  Color(0xFF3D1D8E), // deeper indigo
  Color(0xFF1E0E5E), // very deep blue-violet
];

// Profile: deeper, muted, more intimate
const profileGradientColors = [
  Color(0xFF8333CC), // muted violet
  Color(0xFF6B2DBD),
  Color(0xFF3E1878), // dark plum
  Color(0xFF1C0A45), // near-black violet
];
