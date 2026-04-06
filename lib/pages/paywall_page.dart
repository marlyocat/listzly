import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:listzly/models/subscription_tier.dart';
import 'package:listzly/providers/subscription_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/responsive.dart';

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

    // Same fallback as SubscriptionService: check all active subscriptions
    // in case the entitlement still points to an old personal-pro product.
    final subs = customerInfo.activeSubscriptions;
    if (subs.contains('teacher_premium_monthly')) {
      return SubscriptionTier.teacherPremium;
    }
    if (subs.contains('teacher_pro_monthly')) {
      return SubscriptionTier.teacherPro;
    }
    if (subs.contains('teacher_lite_monthly')) {
      return SubscriptionTier.teacherLite;
    }

    return SubscriptionTier.pro;
  }

  /// Returns the product identifier of the user's current active subscription,
  /// or null if there is none. Used on Android to trigger an upgrade/downgrade
  /// instead of a separate new subscription.
  Future<String?> _currentActiveProductId() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final entitlement = info.entitlements.active['pro'];
      return entitlement?.productIdentifier;
    } catch (_) {
      return null;
    }
  }

  Future<void> _purchase(Package package) async {
    if (_purchasing) return;
    setState(() => _purchasing = true);

    try {
      // On Android, if the user already has an active subscription, pass it as
      // the old product so Google Play treats this as an upgrade/downgrade
      // rather than creating a second subscription.
      GoogleProductChangeInfo? changeInfo;
      if (Platform.isAndroid) {
        final oldProductId = await _currentActiveProductId();
        if (oldProductId != null &&
            oldProductId != package.storeProduct.identifier) {
          changeInfo = GoogleProductChangeInfo(
            oldProductId,
            prorationMode:
                GoogleProrationMode.immediateWithTimeProration,
          );
        }
      }

      final result = await Purchases.purchase(PurchaseParams.package(
        package,
        googleProductChangeInfo: changeInfo,
      ));
      final newTier = _tierFromPurchase(result.customerInfo);

      if (mounted) {
        ref.read(ownSubscriptionTierProvider.notifier).setTier(newTier);
        ref.invalidate(subscriptionInfoProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome to Listzly ${newTier.displayName}!',
              style: TextStyle(fontFamily: 'Nunito',fontWeight: FontWeight.w700),
            ),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            duration: const Duration(seconds: 3),
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
              style: TextStyle(fontFamily: 'Nunito',fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            duration: const Duration(seconds: 3),
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
              style: TextStyle(fontFamily: 'Nunito',fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            duration: const Duration(seconds: 3),
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
              style: TextStyle(fontFamily: 'Nunito',fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  /// Whether this student is in a teacher's group.
  /// Students in a group cannot purchase their own subscription — they must
  /// leave the group first.
  bool _isStudentInGroup(WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile == null || !profile.isStudent) return false;
    final membershipAsync = ref.watch(studentMembershipProvider);
    // While loading, assume in group (safe default — prevents accidental purchase)
    if (membershipAsync.isLoading) return true;
    return membershipAsync.value != null;
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = ref.watch(effectiveSubscriptionTierProvider);
    final subInfo = ref.watch(subscriptionInfoProvider).value;
    final isCancelled = subInfo?.isCancelled ?? false;
    final profile = ref.watch(currentProfileProvider).value;
    final isTeacher = profile?.isTeacher ?? false;
    final studentInGroup = _isStudentInGroup(ref);

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: ContentConstraint(
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
                  if (!studentInGroup)
                    GestureDetector(
                      onTap: _purchasing ? null : _restore,
                      child: Text(
                        'Restore',
                        style: TextStyle(fontFamily: 'Nunito',
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
                style: TextStyle(fontFamily: 'DM Serif Display',
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Unlock your full potential',
              style: TextStyle(fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Content
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
                                  style: TextStyle(fontFamily: 'Nunito',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: darkTextSecondary,
                                  ),
                                ),
                              ),
                            )
                          : studentInGroup
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.groups_rounded,
                                          size: 48,
                                          color: darkTextMuted,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'You\'re part of a teacher\'s group',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontFamily: 'Nunito',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Leave your teacher\'s group first to purchase your own subscription.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontFamily: 'Nunito',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: darkTextSecondary,
                                          ),
                                        ),
                                      ],
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
                                      'All 4 instruments',
                                      'Practice timer with tracking',
                                      'Current streak & total XP',
                                      '7-day activity history',
                                      '3 daily quests',
                                    ],
                                    isCurrentPlan: currentTier.isFree,
                                    accentColor: darkTextMuted,
                                  ),
                                  const SizedBox(height: 12),
                                  if (!isTeacher) ...[
                                    // Self-learner / student: Personal Pro
                                    _buildPlanCard(
                                      title: 'Personal Pro',
                                      price: _getPrice(
                                          'personal_pro_yearly', '\$7.99'),
                                      period: '/year',
                                      features: [
                                        'Full activity history',
                                        'Recording & playback',
                                        'Music Player with favorites & uploads',
                                        'Unlimited quest history',
                                      ],
                                      isCurrentPlan:
                                          currentTier == SubscriptionTier.pro &&
                                              !isCancelled,
                                      isPopular: true,
                                      accentColor: accentCoral,
                                      trialInfo: _getTrialInfo('personal_pro_yearly'),
                                      onTap: () =>
                                          _purchaseProduct('personal_pro_yearly'),
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
                                        'Up to 10 students',
                                        'Assigned quests',
                                        'View student recordings & stats',
                                        'Group notifications',
                                        'Students get Pro free',
                                        'Full activity history',
                                        'Recording & playback',
                                        'Music Player',
                                      ],
                                      isCurrentPlan: currentTier ==
                                              SubscriptionTier.teacherLite &&
                                          !isCancelled,
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
                                        'Up to 25 students',
                                        'Assigned quests',
                                        'View student recordings & stats',
                                        'Group notifications',
                                        'Students get Pro free',
                                        'Full activity history',
                                        'Recording & playback',
                                        'Music Player',
                                      ],
                                      isCurrentPlan: currentTier ==
                                              SubscriptionTier.teacherPro &&
                                          !isCancelled,
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
                                        'Up to 50 students',
                                        'Assigned quests',
                                        'View student recordings & stats',
                                        'Group notifications',
                                        'Students get Pro free',
                                        'Full activity history',
                                        'Recording & playback',
                                        'Music Player',
                                      ],
                                      isCurrentPlan: currentTier ==
                                              SubscriptionTier.teacherPremium &&
                                          !isCancelled,
                                      accentColor: accentCoral,
                                      trialInfo: _getTrialInfo(
                                          'teacher_premium_monthly'),
                                      onTap: () => _purchaseProduct(
                                          'teacher_premium_monthly'),
                                    ),
                                  ],
                                  if (!currentTier.isFree) ...[
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () async {
                                        final messenger =
                                            ScaffoldMessenger.of(context);
                                        try {
                                          final customerInfo =
                                              await Purchases.getCustomerInfo();
                                          final url =
                                              customerInfo.managementURL;
                                          if (url != null) {
                                            await launchUrl(Uri.parse(url),
                                                mode: LaunchMode
                                                    .externalApplication);
                                            if (mounted) {
                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'If you recently cancelled, it may take a few minutes for changes to reflect.',
                                                    style: TextStyle(fontFamily: 'Nunito',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  duration: const Duration(
                                                      seconds: 6),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          debugPrint('Failed to launch management URL: $e');
                                        }
                                      },
                                      child: Text(
                                        'Cancel Subscription',
                                        style: TextStyle(fontFamily: 'Nunito',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: darkTextMuted,
                                          decoration:
                                              TextDecoration.underline,
                                          decorationColor: darkTextMuted,
                                        ),
                                      ),
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
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontFamily: 'DM Serif Display',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              if (isPopular)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentCoral.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'RECOMMENDED',
                    style: TextStyle(fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: accentCoral,
                    ),
                  ),
                ),
              if (isCurrentPlan)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Text(
                    'CURRENT',
                    style: TextStyle(fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: darkTextMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  price,
                  style: TextStyle(fontFamily: 'DM Serif Display',
                    fontSize: 28,
                    color: accentColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  period,
                  style: TextStyle(fontFamily: 'Nunito',
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
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Text(
                trialInfo,
                style: TextStyle(fontFamily: 'Nunito',
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
                  Flexible(
                    child: Text(
                      f,
                      style: TextStyle(fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accentCoral, accentCoralDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
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
                  _purchasing
                      ? 'Processing...'
                      : trialInfo != null
                          ? 'Start free trial'
                          : 'Subscribe',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Nunito',
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
