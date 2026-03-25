import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:listzly/models/song.dart';
import 'package:listzly/providers/music_provider.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/responsive.dart';

class BackgroundMusicPage extends ConsumerWidget {
  const BackgroundMusicPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songListProvider);
    final musicState = ref.watch(musicPlayerProvider);
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

            // Now playing card (if a song is active)
            if (currentSong != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _NowPlayingCard(musicState: musicState),
                ),
              ),

            // Song list
            SliverContentConstraint(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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

                    return Container(
                      decoration: BoxDecoration(
                        color: darkCardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black, width: 5),
                      ),
                      child: Column(
                        children: songs.asMap().entries.map((entry) {
                          final i = entry.key;
                          final song = entry.value;
                          final isActive = currentSong?.id == song.id;

                          return Column(
                            children: [
                              if (i > 0)
                                const Divider(
                                  height: 1,
                                  indent: 52,
                                  endIndent: 16,
                                  color: darkDivider,
                                ),
                              _SongRow(
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
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverContentConstraint(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

/// Spotify-style now playing player.
class _NowPlayingCard extends StatefulWidget {
  final MusicPlayerState musicState;

  const _NowPlayingCard({required this.musicState});

  @override
  State<_NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends State<_NowPlayingCard> {
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
        border: Border(
          top: BorderSide(color: primaryColor.withAlpha(60), width: 1),
          bottom: BorderSide(color: primaryColor.withAlpha(60), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Album art
          Container(
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
            child: const Icon(
              Icons.music_note_rounded,
              color: Colors.white38,
              size: 64,
            ),
          ),
          const SizedBox(height: 20),

          // Song title
          Text(
            song.title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            song.artist,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

class _SongRow extends StatelessWidget {
  final Song song;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SongRow({
    required this.song,
    required this.isActive,
    required this.isPlaying,
    required this.onTap,
  });

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isActive
                    ? accentCoral.withAlpha(30)
                    : Colors.white.withAlpha(10),
              ),
              child: Icon(
                isPlaying
                    ? Icons.equalizer_rounded
                    : Icons.music_note_rounded,
                color: isActive ? accentCoral : Colors.white70,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),

            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isActive ? accentCoral : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
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

            // Duration
            Text(
              _formatDuration(song.durationSeconds),
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: darkTextMuted,
              ),
            ),
          ],
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
