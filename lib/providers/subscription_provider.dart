import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/subscription_tier.dart';
import 'package:listzly/services/subscription_service.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/providers/profile_provider.dart';

part 'subscription_provider.g.dart';

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
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
    });
    ref.onDispose(() => sub.cancel());

    // Fetch initial tier
    _loadTier(service);

    return SubscriptionTier.free;
  }

  Future<void> _loadTier(SubscriptionService service) async {
    state = await service.getCurrentTier();
  }

  void setTier(SubscriptionTier tier) {
    state = tier;
  }
}

/// The effective tier: user's own tier, or teacher's tier if student is in a
/// paid teacher's group (whichever is higher).
@riverpod
SubscriptionTier effectiveSubscriptionTier(EffectiveSubscriptionTierRef ref) {
  final ownTier = ref.watch(ownSubscriptionTierProvider);
  final profile = ref.watch(currentProfileProvider).valueOrNull;

  if (profile == null) return ownTier;

  // If user is a student in a group, check teacher's tier
  if (profile.isStudent) {
    final membership = ref.watch(studentMembershipProvider).valueOrNull;
    if (membership != null) {
      final teacherTier = ref.watch(teacherSubscriptionTierProvider).valueOrNull;
      if (teacherTier != null && teacherTier.index > ownTier.index) {
        return teacherTier;
      }
    }
  }

  return ownTier;
}

/// Fetches the teacher's subscription tier from Supabase profile.
@riverpod
Future<SubscriptionTier> teacherSubscriptionTier(
    TeacherSubscriptionTierRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return SubscriptionTier.free;

  final profileService = ref.watch(profileServiceProvider);
  final teacherProfile = await profileService.getTeacherProfile(user.id);
  if (teacherProfile == null) return SubscriptionTier.free;

  return SubscriptionTier.fromString(teacherProfile.subscriptionTier);
}
