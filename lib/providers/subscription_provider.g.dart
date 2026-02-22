// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionServiceHash() =>
    r'04e393852f53529a6a74b8e40eda96b12973375e';

/// See also [subscriptionService].
@ProviderFor(subscriptionService)
final subscriptionServiceProvider = Provider<SubscriptionService>.internal(
  subscriptionService,
  name: r'subscriptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubscriptionServiceRef = ProviderRef<SubscriptionService>;
String _$effectiveSubscriptionTierHash() =>
    r'4fdcc41f229a79180260b5e42ab3938e5e59ef4b';

/// The effective tier: user's own tier, or teacher's tier if student is in a
/// paid teacher's group (whichever is higher).
///
/// Copied from [effectiveSubscriptionTier].
@ProviderFor(effectiveSubscriptionTier)
final effectiveSubscriptionTierProvider =
    AutoDisposeProvider<SubscriptionTier>.internal(
      effectiveSubscriptionTier,
      name: r'effectiveSubscriptionTierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$effectiveSubscriptionTierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EffectiveSubscriptionTierRef = AutoDisposeProviderRef<SubscriptionTier>;
String _$teacherSubscriptionTierHash() =>
    r'832ef15e2a30af81bb87ce1b8dd0063f3425ad33';

/// Fetches the teacher's subscription tier from Supabase profile.
///
/// Copied from [teacherSubscriptionTier].
@ProviderFor(teacherSubscriptionTier)
final teacherSubscriptionTierProvider =
    AutoDisposeFutureProvider<SubscriptionTier>.internal(
      teacherSubscriptionTier,
      name: r'teacherSubscriptionTierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherSubscriptionTierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherSubscriptionTierRef =
    AutoDisposeFutureProviderRef<SubscriptionTier>;
String _$ownSubscriptionTierHash() =>
    r'defa887881d6fadb8eeb7275e08071715bc35704';

/// The user's own subscription tier from RevenueCat.
///
/// Copied from [OwnSubscriptionTier].
@ProviderFor(OwnSubscriptionTier)
final ownSubscriptionTierProvider =
    NotifierProvider<OwnSubscriptionTier, SubscriptionTier>.internal(
      OwnSubscriptionTier.new,
      name: r'ownSubscriptionTierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ownSubscriptionTierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OwnSubscriptionTier = Notifier<SubscriptionTier>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
