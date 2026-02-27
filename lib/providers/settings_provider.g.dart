// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsService)
final settingsServiceProvider = SettingsServiceProvider._();

final class SettingsServiceProvider
    extends
        $FunctionalProvider<SettingsService, SettingsService, SettingsService>
    with $Provider<SettingsService> {
  SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  $ProviderElement<SettingsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsService create(Ref ref) {
    return settingsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsService>(value),
    );
  }
}

String _$settingsServiceHash() => r'501cf3d1d872f097adda3099151ddd6c1b604563';

@ProviderFor(UserSettingsNotifier)
final userSettingsProvider = UserSettingsNotifierProvider._();

final class UserSettingsNotifierProvider
    extends $AsyncNotifierProvider<UserSettingsNotifier, UserSettings> {
  UserSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSettingsNotifierHash();

  @$internal
  @override
  UserSettingsNotifier create() => UserSettingsNotifier();
}

String _$userSettingsNotifierHash() =>
    r'a12f52a551a912a31b21d49c791d9af336d30921';

abstract class _$UserSettingsNotifier extends $AsyncNotifier<UserSettings> {
  FutureOr<UserSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserSettings>, UserSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserSettings>, UserSettings>,
              AsyncValue<UserSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
