import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/subscription_info.dart';
import 'package:listzly/models/subscription_tier.dart';
import 'package:listzly/services/subscription_service.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/providers/profile_provider.dart';

part 'subscription_provider.g.dart';

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(Ref ref) {
  return SubscriptionService();
}

/// The user's own subscription tier from RevenueCat.
@Riverpod(keepAlive: true)
class OwnSubscriptionTier extends _$OwnSubscriptionTier {
  @override
  SubscriptionTier build() {
    final service = ref.watch(subscriptionServiceProvider);

    // Listen for changes from RevenueCat
    final sub = service.onTierChanged.listen((tier) {
      state = tier;
      _syncToSupabase(tier);
    });
    ref.onDispose(() => sub.cancel());

    // Fetch initial tier
    _loadTier(service);

    return SubscriptionTier.free;
  }

  Future<void> _loadTier(SubscriptionService service) async {
    // Ensure RevenueCat is associated with the current user
    final user = ref.read(currentUserProvider);
    if (user != null) {
      try {
        await Purchases.logIn(user.id);
      } catch (e) {
        debugPrint('RevenueCat logIn failed: $e');
      }
    }

    final tier = await service.getCurrentTier();
    state = tier;
    _syncToSupabase(tier);
  }

  void setTier(SubscriptionTier tier) {
    state = tier;
    _syncToSupabase(tier);
  }

  Future<void> _syncToSupabase(SubscriptionTier tier) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final profileService = ref.read(profileServiceProvider);
      await profileService.updateSubscriptionTier(user.id, tier);
    } catch (e) {
      debugPrint('Failed to sync subscription tier to Supabase: $e');
    }
  }
}

/// The effective tier: user's own tier, or Pro if student is in a teacher's group.
/// A teacher must have a paid plan to create a group, so group membership
/// implies the student should receive Pro benefits.
@riverpod
SubscriptionTier effectiveSubscriptionTier(Ref ref) {
  final ownTier = ref.watch(ownSubscriptionTierProvider);
  final profile = ref.watch(currentProfileProvider).value;

  if (profile == null) return ownTier;

  // If user is a student in a group, they get Pro benefits
  if (profile.isStudent) {
    final membershipAsync = ref.watch(studentMembershipProvider);
    if (membershipAsync.value != null &&
        ownTier.index < SubscriptionTier.pro.index) {
      return SubscriptionTier.pro;
    }
  }

  return ownTier;
}

/// Full subscription details (tier, expiration, renewal status, etc.).
@riverpod
Future<SubscriptionInfo> subscriptionInfo(Ref ref) async {
  // Re-fetch when the user's own tier changes (e.g. after purchase).
  ref.watch(ownSubscriptionTierProvider);
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscriptionInfo();
}

/// Whether the user is eligible for a free trial (has never had 'pro').
@riverpod
Future<bool> isTrialEligible(Ref ref) async {
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    return !customerInfo.entitlements.all.containsKey('pro');
  } catch (e) {
    debugPrint('isTrialEligible error: $e');
    return false;
  }
}
