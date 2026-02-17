// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsServiceHash() => r'9de8de87c78dcd8aa8a7691834c275e7765d2224';

/// See also [settingsService].
@ProviderFor(settingsService)
final settingsServiceProvider = AutoDisposeProvider<SettingsService>.internal(
  settingsService,
  name: r'settingsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsServiceRef = AutoDisposeProviderRef<SettingsService>;
String _$userSettingsNotifierHash() =>
    r'a12f52a551a912a31b21d49c791d9af336d30921';

/// See also [UserSettingsNotifier].
@ProviderFor(UserSettingsNotifier)
final userSettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      UserSettingsNotifier,
      UserSettings
    >.internal(
      UserSettingsNotifier.new,
      name: r'userSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserSettingsNotifier = AutoDisposeAsyncNotifier<UserSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
