// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subscriptionService)
final subscriptionServiceProvider = SubscriptionServiceProvider._();

final class SubscriptionServiceProvider
    extends
        $FunctionalProvider<
          SubscriptionService,
          SubscriptionService,
          SubscriptionService
        >
    with $Provider<SubscriptionService> {
  SubscriptionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionServiceHash();

  @$internal
  @override
  $ProviderElement<SubscriptionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubscriptionService create(Ref ref) {
    return subscriptionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionService>(value),
    );
  }
}

String _$subscriptionServiceHash() =>
    r'0e30a076ad1c35216c1df99c43a0c160eabe00a0';

/// The user's own subscription tier from RevenueCat.

@ProviderFor(OwnSubscriptionTier)
final ownSubscriptionTierProvider = OwnSubscriptionTierProvider._();

/// The user's own subscription tier from RevenueCat.
final class OwnSubscriptionTierProvider
    extends $NotifierProvider<OwnSubscriptionTier, SubscriptionTier> {
  /// The user's own subscription tier from RevenueCat.
  OwnSubscriptionTierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownSubscriptionTierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownSubscriptionTierHash();

  @$internal
  @override
  OwnSubscriptionTier create() => OwnSubscriptionTier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionTier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionTier>(value),
    );
  }
}

String _$ownSubscriptionTierHash() =>
    r'88d84bba7db2d74470babc380f42655a303ba30d';

/// The user's own subscription tier from RevenueCat.

abstract class _$OwnSubscriptionTier extends $Notifier<SubscriptionTier> {
  SubscriptionTier build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SubscriptionTier, SubscriptionTier>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SubscriptionTier, SubscriptionTier>,
              SubscriptionTier,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The effective tier: user's own tier, or Pro if student is in a teacher's group.
/// A teacher must have a paid plan to create a group, so group membership
/// implies the student should receive Pro benefits.

@ProviderFor(effectiveSubscriptionTier)
final effectiveSubscriptionTierProvider = EffectiveSubscriptionTierProvider._();

/// The effective tier: user's own tier, or Pro if student is in a teacher's group.
/// A teacher must have a paid plan to create a group, so group membership
/// implies the student should receive Pro benefits.

final class EffectiveSubscriptionTierProvider
    extends
        $FunctionalProvider<
          SubscriptionTier,
          SubscriptionTier,
          SubscriptionTier
        >
    with $Provider<SubscriptionTier> {
  /// The effective tier: user's own tier, or Pro if student is in a teacher's group.
  /// A teacher must have a paid plan to create a group, so group membership
  /// implies the student should receive Pro benefits.
  EffectiveSubscriptionTierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveSubscriptionTierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveSubscriptionTierHash();

  @$internal
  @override
  $ProviderElement<SubscriptionTier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SubscriptionTier create(Ref ref) {
    return effectiveSubscriptionTier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionTier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionTier>(value),
    );
  }
}

String _$effectiveSubscriptionTierHash() =>
    r'8c510927e66d808469292f4351551ca0f3a2836d';

/// Full subscription details (tier, expiration, renewal status, etc.).

@ProviderFor(subscriptionInfo)
final subscriptionInfoProvider = SubscriptionInfoProvider._();

/// Full subscription details (tier, expiration, renewal status, etc.).

final class SubscriptionInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionInfo>,
          SubscriptionInfo,
          FutureOr<SubscriptionInfo>
        >
    with $FutureModifier<SubscriptionInfo>, $FutureProvider<SubscriptionInfo> {
  /// Full subscription details (tier, expiration, renewal status, etc.).
  SubscriptionInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionInfoHash();

  @$internal
  @override
  $FutureProviderElement<SubscriptionInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionInfo> create(Ref ref) {
    return subscriptionInfo(ref);
  }
}

String _$subscriptionInfoHash() => r'c17e05f78c0efebc7d772a7e1a924f2dbd4d22b1';

/// Whether the user is eligible for a free trial (has never had 'pro').

@ProviderFor(isTrialEligible)
final isTrialEligibleProvider = IsTrialEligibleProvider._();

/// Whether the user is eligible for a free trial (has never had 'pro').

final class IsTrialEligibleProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the user is eligible for a free trial (has never had 'pro').
  IsTrialEligibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isTrialEligibleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isTrialEligibleHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isTrialEligible(ref);
  }
}

String _$isTrialEligibleHash() => r'356f43fb5c7f2816bfeb6df0b0d2de47f6384ee9';
