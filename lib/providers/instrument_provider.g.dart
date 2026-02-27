// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instrument_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Per-instrument stats for Profile page (minutes + sessions).

@ProviderFor(instrumentStats)
final instrumentStatsProvider = InstrumentStatsProvider._();

/// Per-instrument stats for Profile page (minutes + sessions).

final class InstrumentStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Per-instrument stats for Profile page (minutes + sessions).
  InstrumentStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'instrumentStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instrumentStatsHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return instrumentStats(ref);
  }
}

String _$instrumentStatsHash() => r'f2bf14beb4894ec46d045fc2b1a457fc80611b59';
