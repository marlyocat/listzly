import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:listzly/models/subscription_tier.dart';
import 'package:listzly/providers/subscription_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/theme/colors.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  Offerings? _offerings;
  bool _loading = true;
  bool _purchasing = false;
  bool _trialEligible = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final results = await Future.wait([
        Purchases.getOfferings(),
        Purchases.getCustomerInfo(),
      ]);
      if (mounted) {
        final customerInfo = results[1] as CustomerInfo;
        setState(() {
          _offerings = results[0] as Offerings;
          _trialEligible = !customerInfo.entitlements.all.containsKey('pro');
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load plans. Please try again.';
          _loading = false;
        });
      }
    }
  }

  SubscriptionTier _tierFromPurchase(CustomerInfo customerInfo) {
    final proEntitlement = customerInfo.entitlements.active['pro'];
    if (proEntitlement == null) return SubscriptionTier.free;

    final productId = proEntitlement.productIdentifier;
    if (productId == 'teacher_premium_monthly') {
      return SubscriptionTier.teacherPremium;
    }
    if (productId == 'teacher_pro_monthly') {
      return SubscriptionTier.teacherPro;
    }
    if (productId == 'teacher_lite_monthly') {
      return SubscriptionTier.teacherLite;
    }
    return SubscriptionTier.pro;
  }

  Future<void> _purchase(Package package) async {
    if (_purchasing) return;
    setState(() => _purchasing = true);

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final newTier = _tierFromPurchase(customerInfo);

      if (mounted) {
        ref.read(ownSubscriptionTierProvider.notifier).setTier(newTier);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome to Listzly ${newTier.displayName}!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            backgroundColor: accentCoralDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on PurchasesErrorCode catch (_) {
      // User cancelled — do nothing
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Purchase failed. Please try again.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: accentCoralDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      final customerInfo = await Purchases.restorePurchases();
      final newTier = _tierFromPurchase(customerInfo);

      if (mounted) {
        ref.read(ownSubscriptionTierProvider.notifier).setTier(newTier);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newTier.isFree
                  ? 'No previous purchases found.'
                  : 'Restored ${newTier.displayName} plan!',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: accentCoralDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (!newTier.isFree) Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not restore purchases.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: accentCoralDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = ref.watch(effectiveSubscriptionTierProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final isTeacher = profile?.isTeacher ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _purchasing ? null : _restore,
                    child: Text(
                      'Restore',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: accentCoral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, accentCoral],
              ).createShader(bounds),
              child: Text(
                'Upgrade to Pro',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Unlock your full potential',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Plans
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: accentCoral),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: darkTextSecondary,
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // Free plan (always shown)
                              _buildPlanCard(
                                title: 'Free',
                                price: '\$0',
                                period: 'forever',
                                features: [
                                  '1 instrument',
                                  'Daily quests',
                                  'Streaks & XP',
                                ],
                                isCurrentPlan: currentTier.isFree,
                                accentColor: darkTextMuted,
                              ),
                              const SizedBox(height: 12),
                              if (!isTeacher) ...[
                                // Self-learner: Personal Pro
                                _buildPlanCard(
                                  title: 'Personal Pro',
                                  price: _getPrice(
                                      'pro_yearly', '\$7.99'),
                                  period: '/year',
                                  features: [
                                    'All 4 instruments',
                                    'Activity tracking & stats',
                                    'Recordings',
                                    'Sheet music scanner',
                                  ],
                                  isCurrentPlan:
                                      currentTier == SubscriptionTier.pro,
                                  isPopular: true,
                                  accentColor: accentCoral,
                                  trialInfo: _getTrialInfo('pro_yearly'),
                                  onTap: () =>
                                      _purchaseProduct('pro_yearly'),
                                ),
                              ],
                              if (isTeacher) ...[
                                // Teacher Lite
                                _buildPlanCard(
                                  title: 'Teacher Lite',
                                  price: _getPrice(
                                      'teacher_lite_monthly', '\$4.99'),
                                  period: '/month',
                                  features: [
                                    'All 4 instruments',
                                    'Activity tracking & stats',
                                    'Recordings',
                                    'Sheet music scanner',
                                    'Up to 10 students',
                                    'Custom quest assignment',
                                    'Students get Pro free',
                                  ],
                                  isCurrentPlan: currentTier ==
                                      SubscriptionTier.teacherLite,
                                  accentColor: accentCoral,
                                  trialInfo: _getTrialInfo(
                                      'teacher_lite_monthly'),
                                  onTap: () => _purchaseProduct(
                                      'teacher_lite_monthly'),
                                ),
                                const SizedBox(height: 12),
                                // Teacher Pro
                                _buildPlanCard(
                                  title: 'Teacher Pro',
                                  price: _getPrice(
                                      'teacher_pro_monthly', '\$9.99'),
                                  period: '/month',
                                  features: [
                                    'All 4 instruments',
                                    'Activity tracking & stats',
                                    'Recordings',
                                    'Sheet music scanner',
                                    'Up to 25 students',
                                    'Custom quest assignment',
                                    'Students get Pro free',
                                  ],
                                  isCurrentPlan: currentTier ==
                                      SubscriptionTier.teacherPro,
                                  isPopular: true,
                                  accentColor: accentCoral,
                                  trialInfo: _getTrialInfo(
                                      'teacher_pro_monthly'),
                                  onTap: () => _purchaseProduct(
                                      'teacher_pro_monthly'),
                                ),
                                const SizedBox(height: 12),
                                // Teacher Premium
                                _buildPlanCard(
                                  title: 'Teacher Premium',
                                  price: _getPrice(
                                      'teacher_premium_monthly', '\$14.99'),
                                  period: '/month',
                                  features: [
                                    'All 4 instruments',
                                    'Activity tracking & stats',
                                    'Recordings',
                                    'Sheet music scanner',
                                    'Up to 50 students',
                                    'Custom quest assignment',
                                    'Students get Pro free',
                                  ],
                                  isCurrentPlan: currentTier ==
                                      SubscriptionTier.teacherPremium,
                                  accentColor: accentCoral,
                                  trialInfo: _getTrialInfo(
                                      'teacher_premium_monthly'),
                                  onTap: () => _purchaseProduct(
                                      'teacher_premium_monthly'),
                                ),
                              ],
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrice(String identifier, String fallback) {
    final offering = _offerings?.current;
    final package = offering?.availablePackages
        .where((p) => p.identifier == identifier)
        .firstOrNull;
    return package?.storeProduct.priceString ?? fallback;
  }

  void _purchaseProduct(String identifier) {
    final offering = _offerings?.current;
    final package = offering?.availablePackages
        .where((p) => p.identifier == identifier)
        .firstOrNull;
    if (package != null) _purchase(package);
  }

  String? _getTrialInfo(String identifier) {
    if (!_trialEligible) return null;
    final offering = _offerings?.current;
    final package = offering?.availablePackages
        .where((p) => p.identifier == identifier)
        .firstOrNull;
    final intro = package?.storeProduct.introductoryPrice;
    if (intro == null || intro.price != 0) return null;
    final count = intro.periodNumberOfUnits;
    final unit = intro.periodUnit == PeriodUnit.day
        ? count == 1
            ? 'day'
            : 'days'
        : intro.periodUnit == PeriodUnit.week
            ? count == 1
                ? 'week'
                : 'weeks'
            : intro.periodUnit == PeriodUnit.month
                ? count == 1
                    ? 'month'
                    : 'months'
                : count == 1
                    ? 'year'
                    : 'years';
    return '$count-$unit free trial';
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isCurrentPlan,
    required Color accentColor,
    String? trialInfo,
    bool isPopular = false,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? accentCoral : Colors.black,
          width: isPopular ? 2 : 5,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: accentCoral.withAlpha(30),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              if (isPopular) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentCoral.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'RECOMMENDED',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: accentCoral,
                    ),
                  ),
                ),
              ],
              if (isCurrentPlan) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CURRENT',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: darkTextMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  color: accentColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  period,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkTextMuted,
                  ),
                ),
              ),
            ],
          ),
          if (trialInfo != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accentCoral.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                trialInfo,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentCoral,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Features
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    f,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button
          if (!isCurrentPlan && onTap != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _purchasing ? null : onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF4A68E), accentCoralDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _purchasing
                      ? 'Processing...'
                      : trialInfo != null
                          ? 'Start free trial'
                          : 'Subscribe',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
