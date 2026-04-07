import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/subscription_provider.dart';
import 'package:listzly/theme/colors.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
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

class _UpgradePromptSheet extends ConsumerStatefulWidget {
  final String feature;
  const _UpgradePromptSheet({required this.feature});

  @override
  ConsumerState<_UpgradePromptSheet> createState() =>
      _UpgradePromptSheetState();
}

class _UpgradePromptSheetState extends ConsumerState<_UpgradePromptSheet> {
  String? _localizedPrice;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    try {
      final offerings = await Purchases.getOfferings();
      final isTeacher =
          ref.read(currentProfileProvider).value?.isTeacher ?? false;
      final packageId =
          isTeacher ? 'teacher_lite_monthly' : 'personal_pro_monthly';
      final package = offerings.current?.availablePackages
          .where((p) => p.identifier == packageId)
          .firstOrNull;
      if (package != null && mounted) {
        setState(() => _localizedPrice = package.storeProduct.priceString);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher =
        ref.watch(currentProfileProvider).value?.isTeacher ?? false;
    final planName = isTeacher ? 'Teacher Lite' : 'Personal Pro';
    final trialEligible =
        ref.watch(isTrialEligibleProvider).value ?? false;
    final period = isTeacher ? '/month' : '/year';
    final priceText = _localizedPrice != null
        ? trialEligible
            ? 'Free for 14 days, then $_localizedPrice$period'
            : 'Only $_localizedPrice$period'
        : '';

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

          // Crown icon
          SvgPicture.asset(
            'lib/images/licensed/svg/crown.svg',
            width: 72,
            height: 72,
          ),
          const SizedBox(height: 20),

          Text(
            'Upgrade to $planName',
            style: TextStyle(fontFamily: 'DM Serif Display',
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '${widget.feature} is available on the $planName plan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextSecondary,
            ),
          ),
          if (priceText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              priceText,
              style: TextStyle(fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: darkTextMuted,
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Upgrade button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 600),
                  reverseTransitionDuration:
                      const Duration(milliseconds: 600),
                  pageBuilder: (_, animation, __) => const PaywallPage(),
                  transitionsBuilder: (_, animation, __, child) {
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accentCoral, accentCoralDark],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accentCoralDark.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Text(
                'View Plans',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Nunito',
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
              style: TextStyle(fontFamily: 'Nunito',
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
