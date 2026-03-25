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
