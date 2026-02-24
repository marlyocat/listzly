import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:listzly/theme/colors.dart';

/// Shows a mini audio player bottom sheet for playing a recording.
///
/// Provide either [url] for remote playback or [filePath] for local playback.
Future<void> showRecordingPlayer(
  BuildContext context, {
  String? url,
  String? filePath,
  required String instrumentName,
  required String date,
}) {
  assert(url != null || filePath != null, 'Provide either url or filePath');
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RecordingPlayerSheet(
      url: url,
      filePath: filePath,
      instrumentName: instrumentName,
      date: date,
    ),
  );
}

class _RecordingPlayerSheet extends StatefulWidget {
  final String? url;
  final String? filePath;
  final String instrumentName;
  final String date;

  const _RecordingPlayerSheet({
    this.url,
    this.filePath,
    required this.instrumentName,
    required this.date,
  });

  @override
  State<_RecordingPlayerSheet> createState() => _RecordingPlayerSheetState();
}

class _RecordingPlayerSheetState extends State<_RecordingPlayerSheet> {
  late final AudioPlayer _player;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.filePath != null) {
        await _player.setFilePath(widget.filePath!);
      } else {
        await _player.setUrl(widget.url!);
      }
      setState(() => _isLoading = false);
      await _player.play();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Could not load recording';
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF1E0E3D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 5),
          left: BorderSide(color: Colors.black, width: 5),
          right: BorderSide(color: Colors.black, width: 5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: darkTextMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            '${widget.instrumentName} Recording',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.date,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkTextMuted,
            ),
          ),
          const SizedBox(height: 24),

          if (_error != null)
            Text(
              _error!,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade300,
              ),
            )
          else if (_isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: accentCoral,
              ),
            )
          else ...[
            // Seek slider
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _player.duration ?? Duration.zero;
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: accentCoral,
                        inactiveTrackColor: darkSurfaceBg,
                        thumbColor: accentCoral,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                        trackHeight: 3,
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14),
                      ),
                      child: Slider(
                        min: 0,
                        max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                        value: position.inMilliseconds
                            .toDouble()
                            .clamp(0, duration.inMilliseconds.toDouble()),
                        onChanged: (value) {
                          _player
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: darkTextMuted,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: GoogleFonts.nunito(
                              fontSize: 12,
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
            const SizedBox(height: 16),

            // Play/Pause button
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final playing = playerState?.playing ?? false;
                final completed =
                    playerState?.processingState == ProcessingState.completed;

                return GestureDetector(
                  onTap: () {
                    if (completed) {
                      _player.seek(Duration.zero);
                      _player.play();
                    } else if (playing) {
                      _player.pause();
                    } else {
                      _player.play();
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF4A68E), accentCoralDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentCoral.withAlpha(100),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      completed
                          ? Icons.replay_rounded
                          : playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
