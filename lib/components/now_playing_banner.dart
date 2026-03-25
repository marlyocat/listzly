import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:listzly/providers/music_provider.dart';
import 'package:listzly/theme/colors.dart';

/// Spotify-style "Now Playing" mini banner shown above the bottom nav bar.
class NowPlayingBanner extends ConsumerWidget {
  const NowPlayingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicPlayerProvider);

    return ValueListenableBuilder<int>(
      valueListenable: musicStateNotifier,
      builder: (context, _, __) {
        final song = musicState.currentSong;
        if (song == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2D1066), Color(0xFF1E0A4A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              top: BorderSide(
                color: primaryColor.withAlpha(80),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Album art / music icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [primaryColor, primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Song info
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

              // Skip previous
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                size: 22,
                onTap: () => musicState.skipPrevious(),
              ),
              const SizedBox(width: 4),

              // Play/Pause
              StreamBuilder<PlayerState>(
                stream: musicState.player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  final loading = musicState.isLoading;

                  if (loading) {
                    return const SizedBox(
                      width: 32,
                      height: 32,
                      child: Padding(
                        padding: EdgeInsets.all(6),
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
                    size: 28,
                    onTap: () => musicState.togglePlayPause(),
                  );
                },
              ),
              const SizedBox(width: 4),

              // Skip next
              _ControlButton(
                icon: Icons.skip_next_rounded,
                size: 22,
                onTap: () => musicState.skipNext(),
              ),
              const SizedBox(width: 8),

              // Close
              _ControlButton(
                icon: Icons.close_rounded,
                size: 20,
                onTap: () => musicState.stop(),
              ),
            ],
          ),
        );
      },
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
