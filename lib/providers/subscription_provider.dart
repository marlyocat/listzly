import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/subscription_info.dart';
import 'package:listzly/models/subscription_tier.dart';
import 'package:listzly/services/subscription_service.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/providers/profile_provider.dart';

part 'subscription_provider.g.dart';

/// Increments every time the app resumes from background.
/// Providers that watch this will automatically re-fetch on resume.
@Riverpod(keepAlive: true)
class AppResumeCount extends _$AppResumeCount {
  _AppResumeObserver? _observer;

  @override
  int build() {
    _observer = _AppResumeObserver(() => state = state + 1);
    WidgetsBinding.instance.addObserver(_observer!);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(_observer!);
    });
    return 0;
  }
}

class _AppResumeObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  _AppResumeObserver(this.onResume);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(Ref ref) {
  return SubscriptionService();
}

/// The user's own subscription tier from RevenueCat.
@Riverpod(keepAlive: true)
class OwnSubscriptionTier extends _$OwnSubscriptionTier {
  bool _loggedIn = false;

  @override
  SubscriptionTier build() {
    _loggedIn = false;
    final service = ref.watch(subscriptionServiceProvider);
    // Re-run when auth state changes (login/logout) so RevenueCat
    // is re-associated with the correct user.
    final user = ref.watch(currentUserProvider);

    // Listen for changes from RevenueCat.
    // Only sync AFTER logIn has completed — before that, RevenueCat
    // may report anonymous/stale data that would overwrite the real tier.
    final sub = service.onTierChanged.listen((tier) {
      state = tier;
      if (_loggedIn) _syncToSupabase(tier);
    });
    ref.onDispose(() => sub.cancel());

    // Fetch initial tier
    if (user != null) {
      _loadTier(service, user.id);
    }

    return SubscriptionTier.free;
  }

  Future<void> _loadTier(SubscriptionService service, String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat logIn failed: $e');
      // Don't proceed — getCustomerInfo would return anonymous/stale data
      // and _syncToSupabase would overwrite the real tier with 'free'.
      return;
    }

    _loggedIn = true;
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
      // Sync both upgrades and downgrades so the database stays accurate.
      // This is safe because _syncToSupabase is only called with real
      // RevenueCat data (from _loadTier or onTierChanged), never with the
      // initial default free state returned by build().
      await profileService.updateSubscriptionTier(user.id, tier);
    } catch (e) {
      debugPrint('Failed to sync subscription tier: $e');
    }
  }
}

/// Temporary: grant all users Pro access for App Hive testing.
/// Set to false when testing is complete.
const _freeAccessForTesting = true;

/// The effective tier: user's own tier, or Pro if student is in a paid
/// teacher's group.
@riverpod
SubscriptionTier effectiveSubscriptionTier(Ref ref) {
  if (_freeAccessForTesting) return SubscriptionTier.pro;

  final ownTier = ref.watch(ownSubscriptionTierProvider);
  final profile = ref.watch(currentProfileProvider).value;

  if (profile == null) return ownTier;

  // Students under a paid teacher get Pro access
  if (profile.isStudent && ownTier.index < SubscriptionTier.pro.index) {
    final membershipAsync = ref.watch(studentMembershipProvider);
    if (membershipAsync.value != null) {
      final teacherTier = ref.watch(teacherSubscriptionTierProvider).value;
      if (teacherTier != null && teacherTier.isPro) {
        return SubscriptionTier.pro;
      }
    }
  }

  return ownTier;
}

/// Fetches the teacher's subscription tier from Supabase via an RPC function
/// that bypasses RLS (students can't read teacher profiles directly).
/// Re-evaluates when the student's group membership changes.
@riverpod
Future<SubscriptionTier> teacherSubscriptionTier(Ref ref) async {
  // Re-fetch when the app resumes so students pick up a teacher's new plan.
  ref.watch(appResumeCountProvider);

  final membership = await ref.watch(studentMembershipProvider.future);
  if (membership == null) return SubscriptionTier.free;

  final client = ref.watch(supabaseClientProvider);

  final result = await client.rpc('get_teacher_subscription_tier', params: {
    'p_group_id': membership.groupId,
  });

  if (result == null) return SubscriptionTier.free;
  return SubscriptionTier.fromString(result as String? ?? 'free');
}

/// Full subscription details (tier, expiration, renewal status, etc.).
@riverpod
Future<SubscriptionInfo> subscriptionInfo(Ref ref) async {
  // Re-fetch when the user's own tier changes (e.g. after purchase).
  ref.watch(ownSubscriptionTierProvider);
  // Re-fetch when app resumes (e.g. after returning from store management).
  ref.watch(appResumeCountProvider);
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
