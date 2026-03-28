import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:listzly/models/song.dart';
import 'package:listzly/services/music_service.dart';
import 'package:listzly/providers/auth_provider.dart';

part 'music_provider.g.dart';

enum MusicLoopMode { off, all, one }

@riverpod
MusicService musicService(Ref ref) =>
    MusicService(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Song>> songList(Ref ref) async {
  return ref.watch(musicServiceProvider).getSongs();
}

String _userKey(String base, String? userId) => '${base}_${userId ?? 'anon'}';

/// Global notifier so widgets can react to favorite changes.
final favoritesNotifier = ValueNotifier<int>(0);

@riverpod
int favoritesNotifierValue(Ref ref) {
  void listener() => ref.invalidateSelf();
  favoritesNotifier.addListener(listener);
  ref.onDispose(() => favoritesNotifier.removeListener(listener));
  return favoritesNotifier.value;
}

@riverpod
Future<Set<String>> favoriteSongIds(Ref ref) async {
  ref.watch(favoritesNotifierValueProvider);
  final userId = ref.watch(currentUserProvider)?.id;
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_userKey('favorite_songs', userId))?.toSet() ?? {};
}

Future<void> toggleFavoriteSong(String songId, String? userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _userKey('favorite_songs', userId);
  final favorites = prefs.getStringList(key)?.toSet() ?? {};
  if (favorites.contains(songId)) {
    favorites.remove(songId);
  } else {
    favorites.add(songId);
  }
  await prefs.setStringList(key, favorites.toList());
  favoritesNotifier.value++;
}

// ---------------------------------------------------------------------------
// Local uploads
// ---------------------------------------------------------------------------

const _localSongsKey = 'local_songs';

final localSongsNotifier = ValueNotifier<int>(0);

@riverpod
int localSongsNotifierValue(Ref ref) {
  void listener() => ref.invalidateSelf();
  localSongsNotifier.addListener(listener);
  ref.onDispose(() => localSongsNotifier.removeListener(listener));
  return localSongsNotifier.value;
}

@riverpod
Future<List<Song>> localSongs(Ref ref) async {
  ref.watch(localSongsNotifierValueProvider);
  final userId = ref.watch(currentUserProvider)?.id;
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList(_userKey(_localSongsKey, userId)) ?? [];
  return raw
      .map((e) => Song.fromJson(jsonDecode(e) as Map<String, dynamic>))
      .toList();
}

Future<Directory> _localMusicDir() async {
  final appDir = await getApplicationDocumentsDirectory();
  final dir = Directory('${appDir.path}/local_music');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// Pick an audio file from the device and save it locally. Returns null if
/// the user cancelled or the limit has been reached.
Future<Song?> pickAndSaveLocalSong(String? userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _userKey(_localSongsKey, userId);
  final existing = prefs.getStringList(key) ?? [];

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac', 'wma'],
    allowMultiple: false,
  );
  if (result == null || result.files.isEmpty) return null;

  final picked = result.files.first;
  if (picked.path == null) return null;

  // Copy to app directory so the file persists
  final dir = await _localMusicDir();
  final fileName =
      '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
  final dest = File('${dir.path}/$fileName');
  await File(picked.path!).copy(dest.path);

  // Try to get duration
  int durationSeconds = 0;
  try {
    final tempPlayer = AudioPlayer();
    final duration = await tempPlayer.setFilePath(dest.path);
    durationSeconds = duration?.inSeconds ?? 0;
    await tempPlayer.dispose();
  } catch (_) {}

  // Extract title from filename (strip extension)
  final title = picked.name.replaceAll(RegExp(r'\.[^.]+$'), '');

  final song = Song(
    id: 'local_$fileName',
    title: title,
    artist: 'My Uploads',
    filePath: dest.path,
    durationSeconds: durationSeconds,
    createdAt: DateTime.now(),
    isLocal: true,
  );

  existing.add(jsonEncode(song.toJson()));
  await prefs.setStringList(key, existing);
  localSongsNotifier.value++;
  return song;
}

Future<void> removeLocalSong(String songId, String? userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _userKey(_localSongsKey, userId);
  final existing = prefs.getStringList(key) ?? [];
  final songs = existing
      .map((e) => Song.fromJson(jsonDecode(e) as Map<String, dynamic>))
      .toList();

  final idx = songs.indexWhere((s) => s.id == songId);
  if (idx == -1) return;

  // Delete the file
  final file = File(songs[idx].filePath);
  if (await file.exists()) await file.delete();

  songs.removeAt(idx);
  await prefs.setStringList(
    key,
    songs.map((s) => jsonEncode(s.toJson())).toList(),
  );
  localSongsNotifier.value++;
}

/// Global notifier that widgets can listen to for music state changes.
final musicStateNotifier = ValueNotifier<int>(0);

/// Holds the global music player state.
class MusicPlayerState {
  final MusicService _service;
  final AudioPlayer _player = AudioPlayer();

  List<Song> _queue = [];
  int _currentIndex = -1;
  Song? _activeSong;
  bool _isLoading = false;
  String? _error;
  MusicLoopMode _loopMode = MusicLoopMode.off;

  MusicPlayerState(this._service) {
    // Track previous state to detect the transition *into* completed.
    ProcessingState lastState = ProcessingState.idle;
    _player.playerStateStream.listen((state) {
      final current = state.processingState;
      if (current == ProcessingState.completed &&
          lastState != ProcessingState.completed) {
        _onSongCompleted();
      }
      lastState = current;
    });
  }

  Future<void> _onSongCompleted() async {
    // MusicLoopMode.one is handled natively by just_audio's LoopMode.one,
    // so completed only fires for off and all.
    if (_loopMode == MusicLoopMode.all) {
      await skipNext();
    } else if (_currentIndex < _queue.length - 1) {
      await skipNext();
    } else {
      await _player.stop();
      _notify();
    }
  }

  void _notify() {
    musicStateNotifier.value++;
  }

  AudioPlayer get player => _player;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : _activeSong;
  List<Song> get queue => _queue;

  /// Update the queue without interrupting playback.
  void updateQueue(List<Song> songs) {
    final current = currentSong;
    _queue = songs;
    if (current != null) {
      final idx = songs.indexWhere((s) => s.id == current.id);
      // If current song is in the list, point to it.
      // If not, set to -1 — playback continues but next skip starts from 0.
      _currentIndex = idx;
    }
  }
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _player.playing;
  bool get hasSong => currentSong != null;
  MusicLoopMode get loopMode => _loopMode;

  void cycleMusicLoopMode() {
    _loopMode = switch (_loopMode) {
      MusicLoopMode.off => MusicLoopMode.all,
      MusicLoopMode.all => MusicLoopMode.one,
      MusicLoopMode.one => MusicLoopMode.off,
    };
    _player.setLoopMode(
      _loopMode == MusicLoopMode.one ? LoopMode.one : LoopMode.off,
    );
    _notify();
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= _queue.length) return;

    _currentIndex = index;
    _activeSong = _queue[index];
    _isLoading = true;
    _error = null;
    _notify();

    try {
      final song = _queue[index];
      if (song.isLocal) {
        await _player.setFilePath(song.filePath);
      } else {
        final url = await _service.getSignedUrl(song.filePath);
        await _player.setUrl(url);
      }
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

  void seekRelative(int seconds) {
    final pos = _player.position + Duration(seconds: seconds);
    final duration = _player.duration ?? Duration.zero;
    _player.seek(Duration(
      milliseconds: pos.inMilliseconds.clamp(0, duration.inMilliseconds),
    ));
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
    _activeSong = null;
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
