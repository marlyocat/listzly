import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:listzly/models/student_summary.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/pages/student_detail_page.dart';
import 'package:listzly/theme/colors.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(teacherGroupProvider);
    final studentsAsync = ref.watch(teacherStudentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF150833),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Students',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Invite code card
            SliverToBoxAdapter(
              child: groupAsync.when(
                data: (group) {
                  if (group == null) return const SizedBox.shrink();
                  final studentCount =
                      studentsAsync.valueOrNull?.length ?? 0;
                  return _buildInviteCodeCard(context, ref, group.inviteCode,
                      group.id, studentCount);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: accentCoral, strokeWidth: 2.5),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Student list
            SliverToBoxAdapter(
              child: studentsAsync.when(
                data: (students) {
                  if (students.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildStudentList(context, ref, students);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: accentCoral, strokeWidth: 2.5),
                  ),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Could not load students.',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkTextMuted,
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCodeCard(BuildContext context, WidgetRef ref,
      String inviteCode, String groupId, int studentCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: heroCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accentCoral.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.vpn_key_rounded,
                      color: accentCoral, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Invite Code',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '$studentCount/20',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Code display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: darkSurfaceBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      inviteCode,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        color: accentCoral,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showQrCode(context, inviteCode),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentCoral.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.qr_code_rounded,
                          color: accentCoral, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invite code copied!',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w600)),
                          backgroundColor: accentCoral,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentCoral.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.copy_rounded,
                          color: accentCoral, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Regenerate button
            Center(
              child: GestureDetector(
                onTap: () async {
                  final groupService = ref.read(groupServiceProvider);
                  await groupService.regenerateInviteCode(groupId);
                  ref.invalidate(teacherGroupProvider);
                },
                child: Text(
                  'Regenerate Code',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: darkTextMuted,
                    decoration: TextDecoration.underline,
                    decorationColor: darkTextMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Icon(Icons.group_add_rounded,
              size: 56, color: darkTextMuted.withAlpha(120)),
          const SizedBox(height: 16),
          Text(
            'No students yet',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your invite code with students to get started',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(
      BuildContext context, WidgetRef ref, List<StudentSummary> students) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 5),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Your Students',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${students.length} student${students.length == 1 ? '' : 's'}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ...List.generate(students.length, (i) {
              final student = students[i];
              return Column(
                children: [
                  const Divider(
                    height: 1,
                    color: darkDivider,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _StudentTile(
                    student: student,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StudentDetailPage(
                            studentId: student.studentId,
                            studentName: student.displayName,
                          ),
                        ),
                      );
                    },
                    onRemove: () async {
                      final confirmed = await _showRemoveDialog(
                          context, student.displayName);
                      if (confirmed == true) {
                        final groupAsync = ref.read(teacherGroupProvider);
                        final group = groupAsync.valueOrNull;
                        if (group != null) {
                          await ref
                              .read(groupServiceProvider)
                              .removeStudent(group.id, student.studentId);
                          ref.invalidate(teacherStudentsProvider);
                        }
                      }
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  void _showQrCode(BuildContext context, String inviteCode) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E0E3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan to Join',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Students can scan this QR code\nto join your group',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: inviteCode,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  inviteCode,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    color: accentCoral,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showRemoveDialog(BuildContext context, String studentName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E0E3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove Student',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to remove $studentName from your group?',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: darkTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: darkTextMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remove',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final StudentSummary student;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _StudentTile({
    required this.student,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: darkSurfaceBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Center(
                child: Text(
                  student.displayName.isNotEmpty
                      ? student.displayName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.displayName,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 14, color: accentCoral.withAlpha(180)),
                      const SizedBox(width: 3),
                      Text(
                        '${student.currentStreak}d',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: darkTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star_rounded,
                          size: 14, color: primaryLight.withAlpha(180)),
                      const SizedBox(width: 3),
                      Text(
                        '${student.totalXp} XP',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove button
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_remove_rounded,
                    color: darkTextMuted, size: 18),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: darkTextSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
