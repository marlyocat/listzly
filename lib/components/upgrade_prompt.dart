import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/subscription_provider.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/pages/paywall_page.dart';

/// Shows a bottom sheet prompting the user to upgrade to Pro.
Future<void> showUpgradePrompt(
  BuildContext context, {
  required String feature,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _UpgradePromptSheet(feature: feature),
  );
}

class _UpgradePromptSheet extends ConsumerWidget {
  final String feature;
  const _UpgradePromptSheet({required this.feature});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTeacher =
        ref.watch(currentProfileProvider).value?.isTeacher ?? false;
    final planName = isTeacher ? 'Teacher Lite' : 'Pro';
    final trialEligible =
        ref.watch(isTrialEligibleProvider).value ?? false;
    final priceText = trialEligible
        ? isTeacher
            ? 'Free for 14 days, then \$4.99/month'
            : 'Free for 14 days, then \$7.99/year'
        : isTeacher
            ? 'Starting at \$4.99/month'
            : 'Only \$7.99/year';

    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF1E0E3D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 5),
          left: BorderSide(color: Colors.black, width: 5),
          right: BorderSide(color: Colors.black, width: 5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: darkTextMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Lock icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentCoral.withAlpha(40),
                  accentCoralDark.withAlpha(40),
                ],
              ),
            ),
            child: const Icon(
              Icons.lock_rounded,
              size: 32,
              color: accentCoral,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Upgrade to $planName',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '$feature is available on the $planName plan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            priceText,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: darkTextMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Upgrade button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallPage()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF4A68E), accentCoralDark],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: accentCoral.withAlpha(80),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                'View Plans',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dismiss
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Not now',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
