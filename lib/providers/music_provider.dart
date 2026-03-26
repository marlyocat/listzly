import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/models/song.dart';
import 'package:listzly/services/music_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'music_provider.g.dart';

@riverpod
MusicService musicService(Ref ref) =>
    MusicService(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Song>> songList(Ref ref) async {
  return ref.watch(musicServiceProvider).getSongs();
}

/// Global notifier that widgets can listen to for music state changes.
final musicStateNotifier = ValueNotifier<int>(0);

/// Holds the global music player state.
class MusicPlayerState {
  final MusicService _service;
  final AudioPlayer _player = AudioPlayer();

  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isLoading = false;
  String? _error;

  MusicPlayerState(this._service) {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipNext();
      }
    });
  }

  void _notify() {
    musicStateNotifier.value++;
  }

  AudioPlayer get player => _player;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;
  List<Song> get queue => _queue;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _player.playing;
  bool get hasSong => currentSong != null;

  Future<void> playSong(int index) async {
    if (index < 0 || index >= _queue.length) return;

    _currentIndex = index;
    _isLoading = true;
    _error = null;
    _notify();

    try {
      final url = await _service.getSignedUrl(_queue[index].filePath);
      await _player.setUrl(url);
      _isLoading = false;
      _notify();
      await _player.play();
    } catch (e) {
      _isLoading = false;
      _error = 'Could not load song';
      debugPrint('Music playback error: $e');
      _notify();
    }
  }

  Future<void> playSongFromList(Song song, List<Song> songs) async {
    _queue = songs;
    final index = songs.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      await playSong(index);
    }
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
    _notify();
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    final next = (_currentIndex + 1) % _queue.length;
    await playSong(next);
  }

  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;
    if ((_player.position.inSeconds) > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final prev = (_currentIndex - 1 + _queue.length) % _queue.length;
    await playSong(prev);
  }

  bool _pausedForPractice = false;

  bool get isPausedForPractice => _pausedForPractice;

  /// Pause playback but keep position so it can resume after practice.
  void pauseForPractice() {
    if (!hasSong) return;
    _pausedForPractice = true;
    _player.pause();
    _notify();
  }

  /// Resume playback if it was paused for practice.
  void resumeAfterPractice() {
    if (!_pausedForPractice || !hasSong) return;
    _pausedForPractice = false;
    _player.play();
    _notify();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentIndex = -1;
    _notify();
  }


  void dispose() {
    _player.dispose();
  }
}

/// Cache of signed cover URLs so we don't re-fetch them.
final Map<String, String> _coverUrlCache = {};

/// Get a signed URL for a cover image, with caching.
@riverpod
Future<String?> coverUrl(Ref ref, String? coverPath) async {
  if (coverPath == null || coverPath.isEmpty) return null;
  if (_coverUrlCache.containsKey(coverPath)) return _coverUrlCache[coverPath];
  final service = ref.watch(musicServiceProvider);
  final url = await service.getCoverUrl(coverPath);
  if (url != null) _coverUrlCache[coverPath] = url;
  return url;
}

/// Single global instance so all widgets share the same player.
MusicPlayerState? _globalMusicPlayer;

@Riverpod(keepAlive: true)
MusicPlayerState musicPlayer(Ref ref) {
  if (_globalMusicPlayer == null) {
    final service = ref.watch(musicServiceProvider);
    _globalMusicPlayer = MusicPlayerState(service);
  }
  return _globalMusicPlayer!;
}
