import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:listzly/models/song.dart';
import 'package:listzly/providers/music_provider.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/responsive.dart';

class BackgroundMusicPage extends ConsumerStatefulWidget {
  const BackgroundMusicPage({super.key});

  @override
  ConsumerState<BackgroundMusicPage> createState() =>
      _BackgroundMusicPageState();
}

class _BackgroundMusicPageState extends ConsumerState<BackgroundMusicPage> {
  bool _playerExpanded = true;

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songListProvider);
    final musicState = ref.watch(musicPlayerProvider);

    return ValueListenableBuilder<int>(
      valueListenable: musicStateNotifier,
      builder: (context, _, __) {
        final currentSong = musicState.currentSong;

        return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverContentConstraint(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Background Music',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (musicState.hasSong)
                      GestureDetector(
                        onTap: () => musicState.shuffle(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(15),
                          ),
                          child: const Icon(
                            Icons.shuffle_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Description
            SliverContentConstraint(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  'Pick a song to play in the background while you practice.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkTextMuted,
                  ),
                ),
              ),
            ),

            // Now playing (expanded = full player, collapsed = mini banner)
            if (currentSong != null)
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: _playerExpanded
                      ? null
                      : () => setState(() => _playerExpanded = true),
                  child: AnimatedCrossFade(
                    firstChild: Column(
                      children: [
                        _NowPlayingCard(musicState: musicState),
                        // Collapse button
                        GestureDetector(
                          onTap: () =>
                              setState(() => _playerExpanded = false),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: darkTextMuted,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    secondChild: _MiniBanner(musicState: musicState),
                    crossFadeState: _playerExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
              ),

            // Song list
            SliverToBoxAdapter(
              child: songsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: accentCoral),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Could not load songs.\nPlease try again later.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkTextMuted,
                      ),
                    ),
                  ),
                ),
                data: (songs) {
                  if (songs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'No songs available yet.',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkTextMuted,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: songs.map((song) {
                      final isActive = currentSong?.id == song.id;
                      return _SongTile(
                        song: song,
                        isActive: isActive,
                        isPlaying: isActive && musicState.isPlaying,
                        onTap: () {
                          if (isActive) {
                            musicState.togglePlayPause();
                          } else {
                            musicState.playSongFromList(song, songs);
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SliverContentConstraint(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
        },
      );
  }
}

/// Collapsed mini banner — tap to expand.
class _MiniBanner extends StatelessWidget {
  final MusicPlayerState musicState;
  const _MiniBanner({required this.musicState});

  @override
  Widget build(BuildContext context) {
    final song = musicState.currentSong;
    if (song == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D1066), Color(0xFF1E0A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  song.title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artist,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkTextMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => musicState.skipPrevious(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.skip_previous_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 4),
          StreamBuilder<PlayerState>(
            stream: musicState.player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return GestureDetector(
                onTap: () => musicState.togglePlayPause(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => musicState.skipNext(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child:
                  Icon(Icons.skip_next_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: darkTextMuted,
            size: 22,
          ),
        ],
      ),
    );
  }
}

/// Spotify-style now playing player.
class _NowPlayingCard extends ConsumerStatefulWidget {
  final MusicPlayerState musicState;

  const _NowPlayingCard({required this.musicState});

  @override
  ConsumerState<_NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends ConsumerState<_NowPlayingCard> {
  double? _dragValue;

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final musicState = widget.musicState;
    final song = musicState.currentSong!;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1066), Color(0xFF1E0A4A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Album art
          Builder(builder: (context) {
            final coverAsync = ref.watch(coverUrlProvider(song.coverUrl));
            return Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3D1A8E), Color(0xFF1E0A4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: coverAsync.when(
                data: (url) => url != null
                    ? Image.network(url, fit: BoxFit.cover, width: 180, height: 180)
                    : const Icon(
                        Icons.music_note_rounded,
                        color: Colors.white38,
                        size: 64,
                      ),
                loading: () => const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white38,
                  size: 64,
                ),
                error: (_, __) => const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white38,
                  size: 64,
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Song title
          _MarqueeText(
            text: song.title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          _MarqueeText(
            text: song.artist,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextMuted,
            ),
          ),
          const SizedBox(height: 16),

          // Seek bar with timestamps
          StreamBuilder<Duration>(
            stream: musicState.player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = musicState.player.duration ?? Duration.zero;
              final maxMs = duration.inMilliseconds.toDouble();
              final posMs = _dragValue ?? position.inMilliseconds.toDouble();

              return Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      activeTrackColor: accentCoral,
                      inactiveTrackColor: Colors.white.withAlpha(30),
                      thumbColor: accentCoral,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayColor: accentCoral.withAlpha(40),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      min: 0,
                      max: maxMs > 0 ? maxMs : 1,
                      value: posMs.clamp(0, maxMs > 0 ? maxMs : 1),
                      onChangeStart: (_) {
                        setState(() => _dragValue = posMs);
                      },
                      onChanged: (v) {
                        setState(() => _dragValue = v);
                      },
                      onChangeEnd: (v) {
                        musicState.player
                            .seek(Duration(milliseconds: v.toInt()));
                        setState(() => _dragValue = null);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _format(Duration(milliseconds: posMs.toInt())),
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: darkTextMuted,
                          ),
                        ),
                        Text(
                          _format(duration),
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: darkTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                size: 32,
                onTap: () => musicState.skipPrevious(),
              ),
              const SizedBox(width: 16),
              StreamBuilder<PlayerState>(
                stream: musicState.player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  if (musicState.isLoading) {
                    return const SizedBox(
                      width: 56,
                      height: 56,
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: accentCoral,
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () => musicState.togglePlayPause(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [accentCoral, accentCoralDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              _ControlButton(
                icon: Icons.skip_next_rounded,
                size: 32,
                onTap: () => musicState.skipNext(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SongTile extends ConsumerWidget {
  final Song song;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SongTile({
    required this.song,
    required this.isActive,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverAsync = ref.watch(coverUrlProvider(song.coverUrl));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isActive ? accentCoral.withAlpha(15) : Colors.transparent,
        child: Row(
          children: [
            // Album art
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: isActive
                      ? [accentCoral.withAlpha(40), accentCoralDark.withAlpha(25)]
                      : [const Color(0xFF3D1A8E), const Color(0xFF1E0A4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: coverAsync.when(
                data: (url) => url != null
                    ? Image.network(url, fit: BoxFit.cover, width: 48, height: 48)
                    : Icon(
                        isPlaying ? Icons.equalizer_rounded : Icons.music_note_rounded,
                        color: isActive ? accentCoral : Colors.white30,
                        size: 22,
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => Icon(
                  Icons.music_note_rounded,
                  color: isActive ? accentCoral : Colors.white30,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title + artist
            Expanded(
              child: ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MarqueeText(
                      text: song.title,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isActive ? accentCoral : Colors.white,
                      ),
                    ),
                    _MarqueeText(
                      text: song.artist,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({required this.text, required this.style});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  late final ScrollController _scrollController;
  bool _overflows = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  @override
  void didUpdateWidget(_MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _scrollController.jumpTo(0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
    }
  }

  void _checkOverflow() {
    if (!mounted) return;
    final overflows = _scrollController.position.maxScrollExtent > 0;
    if (overflows != _overflows) {
      setState(() => _overflows = overflows);
      if (overflows) _startScrolling();
    }
  }

  Future<void> _startScrolling() async {
    while (mounted && _overflows) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_overflows) break;
      final max = _scrollController.position.maxScrollExtent;
      final durationMs = (max * 30).toInt().clamp(2000, 10000);
      await _scrollController.animateTo(
        max,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_overflows) break;
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.style.fontSize! * 1.4,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
