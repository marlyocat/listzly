// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(musicService)
final musicServiceProvider = MusicServiceProvider._();

final class MusicServiceProvider
    extends $FunctionalProvider<MusicService, MusicService, MusicService>
    with $Provider<MusicService> {
  MusicServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicServiceHash();

  @$internal
  @override
  $ProviderElement<MusicService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MusicService create(Ref ref) {
    return musicService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicService>(value),
    );
  }
}

String _$musicServiceHash() => r'a75874249f7666c2420e5ac4503d9d8fe599f079';

@ProviderFor(songList)
final songListProvider = SongListProvider._();

final class SongListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Song>>,
          List<Song>,
          FutureOr<List<Song>>
        >
    with $FutureModifier<List<Song>>, $FutureProvider<List<Song>> {
  SongListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListHash();

  @$internal
  @override
  $FutureProviderElement<List<Song>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Song>> create(Ref ref) {
    return songList(ref);
  }
}

String _$songListHash() => r'ceb7bb969f697930b8a4eb5c8507b6840ee9a7d4';

@ProviderFor(favoritesNotifierValue)
final favoritesNotifierValueProvider = FavoritesNotifierValueProvider._();

final class FavoritesNotifierValueProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  FavoritesNotifierValueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesNotifierValueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesNotifierValueHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return favoritesNotifierValue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$favoritesNotifierValueHash() =>
    r'8262e7b6bb06dae608c153bd13c7ac857b4a6363';

@ProviderFor(favoriteSongIds)
final favoriteSongIdsProvider = FavoriteSongIdsProvider._();

final class FavoriteSongIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  FavoriteSongIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteSongIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteSongIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return favoriteSongIds(ref);
  }
}

String _$favoriteSongIdsHash() => r'df829911b16348ee2d6f08349b6974628d8d128c';

/// Get a signed URL for a cover image, with caching.

@ProviderFor(coverUrl)
final coverUrlProvider = CoverUrlFamily._();

/// Get a signed URL for a cover image, with caching.

final class CoverUrlProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Get a signed URL for a cover image, with caching.
  CoverUrlProvider._({
    required CoverUrlFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'coverUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coverUrlHash();

  @override
  String toString() {
    return r'coverUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String?;
    return coverUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoverUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coverUrlHash() => r'04a0aa093a98e214bda5201ddf416b14e94d2535';

/// Get a signed URL for a cover image, with caching.

final class CoverUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String?> {
  CoverUrlFamily._()
    : super(
        retry: null,
        name: r'coverUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Get a signed URL for a cover image, with caching.

  CoverUrlProvider call(String? coverPath) =>
      CoverUrlProvider._(argument: coverPath, from: this);

  @override
  String toString() => r'coverUrlProvider';
}

@ProviderFor(musicPlayer)
final musicPlayerProvider = MusicPlayerProvider._();

final class MusicPlayerProvider
    extends
        $FunctionalProvider<
          MusicPlayerState,
          MusicPlayerState,
          MusicPlayerState
        >
    with $Provider<MusicPlayerState> {
  MusicPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicPlayerHash();

  @$internal
  @override
  $ProviderElement<MusicPlayerState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MusicPlayerState create(Ref ref) {
    return musicPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicPlayerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicPlayerState>(value),
    );
  }
}

String _$musicPlayerHash() => r'354a63a1e00be8c714a00e8380163e2049b377e7';
