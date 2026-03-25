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
              SliverContentConstraint(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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

/// Card showing the currently playing song with controls.
class _NowPlayingCard extends StatelessWidget {
  final MusicPlayerState musicState;

  const _NowPlayingCard({required this.musicState});

  @override
  Widget build(BuildContext context) {
    final song = musicState.currentSong!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1066), Color(0xFF1E0A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withAlpha(80), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Album art
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [accentCoral, accentCoralDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Song info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Now Playing',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentCoral,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.title,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
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

              // Controls
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                size: 24,
                onTap: () => musicState.skipPrevious(),
              ),
              StreamBuilder<PlayerState>(
                stream: musicState.player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  if (musicState.isLoading) {
                    return const SizedBox(
                      width: 36,
                      height: 36,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accentCoral,
                        ),
                      ),
                    );
                  }
                  return _ControlButton(
                    icon: playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 30,
                    onTap: () => musicState.togglePlayPause(),
                  );
                },
              ),
              _ControlButton(
                icon: Icons.skip_next_rounded,
                size: 24,
                onTap: () => musicState.skipNext(),
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: 10),
          StreamBuilder<Duration>(
            stream: musicState.player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = musicState.player.duration ?? Duration.zero;
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;

              return ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: Colors.white.withAlpha(30),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(accentCoral),
                ),
              );
            },
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
