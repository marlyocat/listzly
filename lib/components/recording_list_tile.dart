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
              // Play button
              GestureDetector(
                onTap: onPlay,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentCoral.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: accentCoral, size: 18),
                ),
              ),
              // More actions menu
              if (onToggleShare != null || onDownload != null || onDelete != null) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: darkTextMuted, size: 20),
                  color: const Color(0xFF1E0E3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 160),
                  onSelected: (value) {
                    switch (value) {
                      case 'share':
                        onToggleShare?.call();
                      case 'download':
                        onDownload?.call();
                      case 'delete':
                        onDelete?.call();
                    }
                  },
                  itemBuilder: (_) => [
                    if (onToggleShare != null)
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(
                              recording.sharedWithTeacher
                                  ? Icons.people_rounded
                                  : Icons.people_outline_rounded,
                              color: recording.sharedWithTeacher
                                  ? accentCoral
                                  : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              recording.sharedWithTeacher
                                  ? 'Unshare with Teacher'
                                  : 'Share with Teacher',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (onDownload != null)
                      PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            const Icon(Icons.download_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Download',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: Colors.red.shade300, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Delete',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
