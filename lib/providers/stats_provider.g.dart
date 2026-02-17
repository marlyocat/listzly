// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statsServiceHash() => r'9e1b5d2d047b7583cdbc39deb55b67c678213d51';

/// See also [statsService].
@ProviderFor(statsService)
final statsServiceProvider = AutoDisposeProvider<StatsService>.internal(
  statsService,
  name: r'statsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatsServiceRef = AutoDisposeProviderRef<StatsService>;
String _$userStatsHash() => r'7b1f923404b6539a917c8a77c48ace29bb61286e';

/// See also [userStats].
@ProviderFor(userStats)
final userStatsProvider = AutoDisposeFutureProvider<UserStats>.internal(
  userStats,
  name: r'userStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserStatsRef = AutoDisposeFutureProviderRef<UserStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
