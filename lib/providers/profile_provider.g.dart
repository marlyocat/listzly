// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileServiceHash() => r'3a7d90e7212e9b95d832ffd4ea8cef8bf79a2c85';

/// See also [profileService].
@ProviderFor(profileService)
final profileServiceProvider = AutoDisposeProvider<ProfileService>.internal(
  profileService,
  name: r'profileServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileServiceRef = AutoDisposeProviderRef<ProfileService>;
String _$currentProfileHash() => r'3b2c321af4138ec4b1ae716932b96ffb059c05b2';

/// See also [currentProfile].
@ProviderFor(currentProfile)
final currentProfileProvider = AutoDisposeFutureProvider<Profile>.internal(
  currentProfile,
  name: r'currentProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentProfileRef = AutoDisposeFutureProviderRef<Profile>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
