// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instrument_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$instrumentStatsHash() => r'ccd79818c451705034126d017a8e8ea955f80b52';

/// Per-instrument stats for Profile page (minutes + sessions).
///
/// Copied from [instrumentStats].
@ProviderFor(instrumentStats)
final instrumentStatsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      instrumentStats,
      name: r'instrumentStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$instrumentStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InstrumentStatsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
