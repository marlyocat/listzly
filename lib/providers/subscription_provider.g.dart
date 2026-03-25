// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Increments every time the app resumes from background.
/// Providers that watch this will automatically re-fetch on resume.

@ProviderFor(AppResumeCount)
final appResumeCountProvider = AppResumeCountProvider._();

/// Increments every time the app resumes from background.
/// Providers that watch this will automatically re-fetch on resume.
final class AppResumeCountProvider
    extends $NotifierProvider<AppResumeCount, int> {
  /// Increments every time the app resumes from background.
  /// Providers that watch this will automatically re-fetch on resume.
  AppResumeCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appResumeCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appResumeCountHash();

  @$internal
  @override
  AppResumeCount create() => AppResumeCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$appResumeCountHash() => r'c92a55fd3e25941fb961bd5c4a7c4d1a66bfe646';

/// Increments every time the app resumes from background.
/// Providers that watch this will automatically re-fetch on resume.

abstract class _$AppResumeCount extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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
    r'645642bdd82d93df0059ae4f16cbd066085a8aa7';

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

/// The effective tier: user's own tier, or Pro if student is in a paid
/// teacher's group.

@ProviderFor(effectiveSubscriptionTier)
final effectiveSubscriptionTierProvider = EffectiveSubscriptionTierProvider._();

/// The effective tier: user's own tier, or Pro if student is in a paid
/// teacher's group.

final class EffectiveSubscriptionTierProvider
    extends
        $FunctionalProvider<
          SubscriptionTier,
          SubscriptionTier,
          SubscriptionTier
        >
    with $Provider<SubscriptionTier> {
  /// The effective tier: user's own tier, or Pro if student is in a paid
  /// teacher's group.
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
    r'17955b40f7d9c5dd2b7a1d2714368d5dac2e1021';

/// Fetches the teacher's subscription tier from Supabase via an RPC function
/// that bypasses RLS (students can't read teacher profiles directly).
/// Re-evaluates when the student's group membership changes.

@ProviderFor(teacherSubscriptionTier)
final teacherSubscriptionTierProvider = TeacherSubscriptionTierProvider._();

/// Fetches the teacher's subscription tier from Supabase via an RPC function
/// that bypasses RLS (students can't read teacher profiles directly).
/// Re-evaluates when the student's group membership changes.

final class TeacherSubscriptionTierProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionTier>,
          SubscriptionTier,
          FutureOr<SubscriptionTier>
        >
    with $FutureModifier<SubscriptionTier>, $FutureProvider<SubscriptionTier> {
  /// Fetches the teacher's subscription tier from Supabase via an RPC function
  /// that bypasses RLS (students can't read teacher profiles directly).
  /// Re-evaluates when the student's group membership changes.
  TeacherSubscriptionTierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teacherSubscriptionTierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teacherSubscriptionTierHash();

  @$internal
  @override
  $FutureProviderElement<SubscriptionTier> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionTier> create(Ref ref) {
    return teacherSubscriptionTier(ref);
  }
}

String _$teacherSubscriptionTierHash() =>
    r'8b9672cce38cbd09edea74ea764818e88fd7c40c';

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

String _$subscriptionInfoHash() => r'baf1b0486ab241cbb056b8f693b5d2d2e3426a5b';

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
