import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/models/practice_recording.dart';
import 'package:listzly/theme/colors.dart';

class RecordingListTile extends StatelessWidget {
  final PracticeRecording recording;
  final VoidCallback onPlay;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleShare;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  const RecordingListTile({
    super.key,
    required this.recording,
    required this.onPlay,
    this.onDownload,
    this.onDelete,
    this.onToggleShare,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0 && s > 0) return '${m}m ${s}s';
    if (m > 0) return '${m}m';
    return '${s}s';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_monthNames[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          height: 1,
          color: darkDivider,
          indent: 16,
          endIndent: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Mic icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: darkSurfaceBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(Icons.mic_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recording.instrumentName,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${_formatDate(recording.createdAt)}  ·  ${_formatDuration(recording.durationSeconds)}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: darkTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentCoral.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: accentCoral, size: 18),
                ),
              ),
              if (onToggleShare != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onToggleShare,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: recording.sharedWithTeacher
                          ? accentCoral.withAlpha(30)
                          : darkSurfaceBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      recording.sharedWithTeacher
                          ? Icons.people_rounded
                          : Icons.people_outline_rounded,
                      color: recording.sharedWithTeacher
                          ? accentCoral
                          : darkTextMuted,
                      size: 16,
                    ),
                  ),
                ),
              ],
              if (onDownload != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDownload,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: darkSurfaceBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.download_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: Colors.red.shade300, size: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
