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
    r'be91f2fac451a18e8e59a25cdaa89ccc9349cf3f';

/// The effective tier: user's own tier, or teacher's tier if student is in a
/// paid teacher's group (only if teacher has teacherPro).
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
String _$isTrialEligibleHash() => r'21bde8626131a96989a134afda8574dcfb6cfc5b';

/// Whether the user is eligible for a free trial (has never had 'pro').
///
/// Copied from [isTrialEligible].
@ProviderFor(isTrialEligible)
final isTrialEligibleProvider = AutoDisposeFutureProvider<bool>.internal(
  isTrialEligible,
  name: r'isTrialEligibleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isTrialEligibleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsTrialEligibleRef = AutoDisposeFutureProviderRef<bool>;
String _$ownSubscriptionTierHash() =>
    r'1c6cdea6b8d1d078fa2a96c0484b72932782d824';

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
