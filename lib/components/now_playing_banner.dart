import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
            children: [
              // Song info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MarqueeText(
                      text: song.title,
                      style: TextStyle(fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    _MarqueeText(
                      text: song.artist,
                      style: TextStyle(fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkTextMuted,
                      ),
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
              const SizedBox(height: 6),
              _SeekBar(player: musicState.player),
            ],
          ),
        );
      },
    );
  }
}

/// Scrolls text horizontally in a loop if it overflows, otherwise static.
class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({required this.text, required this.style});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
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

class _SeekBar extends StatefulWidget {
  final AudioPlayer player;
  const _SeekBar({required this.player});

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: widget.player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = widget.player.duration ?? Duration.zero;
        final maxMs = duration.inMilliseconds.toDouble();
        final posMs = _dragValue ?? position.inMilliseconds.toDouble();

        return Row(
          children: [
            Text(
              _format(Duration(milliseconds: posMs.toInt())),
              style: TextStyle(fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: darkTextMuted,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  activeTrackColor: accentCoral,
                  inactiveTrackColor: Colors.white.withAlpha(30),
                  thumbColor: accentCoral,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 5,
                  ),
                  overlayColor: accentCoral.withAlpha(40),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 10,
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
                    widget.player.seek(Duration(milliseconds: v.toInt()));
                    setState(() => _dragValue = null);
                  },
                ),
              ),
            ),
            Text(
              _format(duration),
              style: TextStyle(fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: darkTextMuted,
              ),
            ),
          ],
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
