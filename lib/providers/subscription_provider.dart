import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

/// The effective tier: user's own tier, or teacher's tier if student is in a
/// paid teacher's group (only if teacher has teacherPro).
@riverpod
SubscriptionTier effectiveSubscriptionTier(Ref ref) {
  final ownTier = ref.watch(ownSubscriptionTierProvider);
  final profile = ref.watch(currentProfileProvider).value;

  if (profile == null) return ownTier;

  // If user is a student in a group, check teacher's tier
  if (profile.isStudent) {
    final membership = ref.watch(studentMembershipProvider).value;
    if (membership != null) {
      final teacherTier =
          ref.watch(teacherSubscriptionTierProvider).value;
      // Only inherit Pro if teacher has teacherPro (studentsInheritPro)
      if (teacherTier != null &&
          teacherTier.studentsInheritPro &&
          ownTier.index < SubscriptionTier.pro.index) {
        return SubscriptionTier.pro;
      }
    }
  }

  return ownTier;
}

/// Fetches the teacher's subscription tier from Supabase profile.
@riverpod
Future<SubscriptionTier> teacherSubscriptionTier(
    Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return SubscriptionTier.free;

  final profileService = ref.watch(profileServiceProvider);
  final teacherProfile = await profileService.getTeacherProfile(user.id);
  if (teacherProfile == null) return SubscriptionTier.free;

  return SubscriptionTier.fromString(teacherProfile.subscriptionTier);
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
