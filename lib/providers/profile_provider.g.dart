// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileService)
final profileServiceProvider = ProfileServiceProvider._();

final class ProfileServiceProvider
    extends $FunctionalProvider<ProfileService, ProfileService, ProfileService>
    with $Provider<ProfileService> {
  ProfileServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileServiceHash();

  @$internal
  @override
  $ProviderElement<ProfileService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileService create(Ref ref) {
    return profileService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileService>(value),
    );
  }
}

String _$profileServiceHash() => r'dac5470bd27e8e032780ae49c3f0e2f52cf81caa';

@ProviderFor(currentProfile)
final currentProfileProvider = CurrentProfileProvider._();

final class CurrentProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, FutureOr<Profile>>
    with $FutureModifier<Profile>, $FutureProvider<Profile> {
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile> create(Ref ref) {
    return currentProfile(ref);
  }
}

String _$currentProfileHash() => r'da7078e84723160ec962a9b8889b185fa0d9fb86';
