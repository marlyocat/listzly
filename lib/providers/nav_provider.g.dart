// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nav_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks the currently selected bottom navigation tab index.

@ProviderFor(NavIndex)
final navIndexProvider = NavIndexProvider._();

/// Tracks the currently selected bottom navigation tab index.
final class NavIndexProvider extends $NotifierProvider<NavIndex, int> {
  /// Tracks the currently selected bottom navigation tab index.
  NavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navIndexHash();

  @$internal
  @override
  NavIndex create() => NavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$navIndexHash() => r'195f81549b6df69a725bf8c55c0b094563e20f42';

/// Tracks the currently selected bottom navigation tab index.

abstract class _$NavIndex extends $Notifier<int> {
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
