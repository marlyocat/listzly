// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statsService)
final statsServiceProvider = StatsServiceProvider._();

final class StatsServiceProvider
    extends $FunctionalProvider<StatsService, StatsService, StatsService>
    with $Provider<StatsService> {
  StatsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsServiceHash();

  @$internal
  @override
  $ProviderElement<StatsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsService create(Ref ref) {
    return statsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsService>(value),
    );
  }
}

String _$statsServiceHash() => r'ac76dc2bb32acd4c2a1a673bc1ecf90871da98df';

@ProviderFor(userStats)
final userStatsProvider = UserStatsProvider._();

final class UserStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserStats>,
          UserStats,
          FutureOr<UserStats>
        >
    with $FutureModifier<UserStats>, $FutureProvider<UserStats> {
  UserStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userStatsHash();

  @$internal
  @override
  $FutureProviderElement<UserStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserStats> create(Ref ref) {
    return userStats(ref);
  }
}

String _$userStatsHash() => r'c82d5f6bcb3803ba6d1edd3b28901c38aaa0c3b0';
