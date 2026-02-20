import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:listzly/models/assigned_quest.dart';
import 'package:listzly/models/student_summary.dart';
import 'package:listzly/providers/assigned_quest_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/pages/assign_quest_sheet.dart';
import 'package:listzly/pages/student_detail_page.dart';
import 'package:listzly/theme/colors.dart';
import 'package:listzly/utils/level_utils.dart';
import 'package:turn_page_transition/turn_page_transition.dart';

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
            // Title + notification bell
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Expanded(
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
                    _buildNotificationBell(context, ref),
                  ],
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

            // Assign quest button + active quests
            SliverToBoxAdapter(
              child: groupAsync.when(
                data: (group) {
                  if (group == null) return const SizedBox.shrink();
                  return _buildAssignedQuestsSection(context, ref, group.id);
                },
                loading: () => const SizedBox.shrink(),
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

  Widget _buildAssignedQuestsSection(
      BuildContext context, WidgetRef ref, String groupId) {
    final activeQuestsAsync = ref.watch(teacherAssignedQuestsProvider);
    final students = ref.watch(teacherStudentsProvider).valueOrNull ?? [];
    final studentNames = {
      for (final s in students) s.studentId: s.displayName,
    };

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
                    'Assigned Quest',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (_) =>
                            AssignQuestDialog(groupId: groupId),
                      );
                      if (result == true) {
                        ref.invalidate(teacherAssignedQuestsProvider);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentCoral.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: accentCoral, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Assign',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: accentCoral,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            activeQuestsAsync.when(
              data: (quests) {
                if (quests.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      'No quests assigned yet',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkTextSecondary,
                      ),
                    ),
                  );
                }
                return _ActiveQuestList(
                  quests: quests,
                  studentNames: studentNames,
                  groupId: groupId,
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(
                      color: accentCoral, strokeWidth: 2.5),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'Could not load quests.',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkTextMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
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
                        border: Border.all(
                            color: Colors.black, width: 2),
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
                        border: Border.all(
                            color: Colors.black, width: 2),
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
                    onTap: () async {
                      final groupAsync = ref.read(teacherGroupProvider);
                      final groupId = groupAsync.valueOrNull?.id;
                      final removed = await Navigator.of(context).push<bool>(
                        PageRouteBuilder(
                          transitionDuration:
                              const Duration(milliseconds: 600),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 300),
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              StudentDetailPage(
                            studentId: student.studentId,
                            studentName: student.displayName,
                            groupId: groupId,
                          ),
                          transitionsBuilder: (context, animation,
                              secondaryAnimation, child) {
                            if (animation.status ==
                                AnimationStatus.reverse) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            }
                            return TurnPageTransition(
                              animation: animation,
                              overleafColor: primaryDark,
                              animationTransitionPoint: 0.5,
                              child: child,
                            );
                          },
                        ),
                      );
                      if (removed == true) {
                        ref.invalidate(teacherStudentsProvider);
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

  Widget _buildNotificationBell(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(unreadGroupNotificationsProvider);
    final count = notificationsAsync.valueOrNull?.length ?? 0;

    return GestureDetector(
      onTap: () => _showNotificationsDialog(context, ref),
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_rounded,
              color: count > 0 ? accentCoral : darkTextMuted,
              size: 26,
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: accentCoral,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, WidgetRef ref) {
    final group = ref.read(teacherGroupProvider).valueOrNull;
    if (group == null) return;

    final hasUnread =
        (ref.read(unreadGroupNotificationsProvider).valueOrNull?.length ?? 0) >
            0;

    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder(
        future: ref.read(groupServiceProvider).getAllNotifications(group.id),
        builder: (ctx, snapshot) {
          final notifications = snapshot.data ?? [];
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting;

          return Dialog(
            backgroundColor: const Color(0xFF1E0E3D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 5),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_rounded,
                          color: accentCoral, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close_rounded,
                            color: darkTextMuted, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(
                            color: accentCoral, strokeWidth: 2.5),
                      ),
                    )
                  else if (notifications.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No notifications yet',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkTextMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    ...notifications.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: n.isRead
                                      ? darkTextMuted.withAlpha(80)
                                      : accentCoral,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  n.message,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: n.isRead
                                        ? darkTextMuted
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  if (notifications.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasUnread)
                          GestureDetector(
                            onTap: () async {
                              await ref
                                  .read(groupServiceProvider)
                                  .markNotificationsRead(group.id);
                              ref.invalidate(
                                  unreadGroupNotificationsProvider);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            child: Text(
                              'Mark all as Read',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: darkTextMuted,
                              ),
                            ),
                          ),
                        if (hasUnread) const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () async {
                            await ref
                                .read(groupServiceProvider)
                                .deleteAllNotifications(group.id);
                            ref.invalidate(
                                unreadGroupNotificationsProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
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

}

class _StudentTile extends StatelessWidget {
  final StudentSummary student;
  final VoidCallback onTap;

  const _StudentTile({
    required this.student,
    required this.onTap,
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
                      Image.asset('lib/images/streak.png',
                          width: 14, height: 14),
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
                      Image.asset('lib/images/xp.png',
                          width: 14, height: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${student.totalXp} XP',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: darkTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset('lib/images/level.png',
                          width: 14, height: 14),
                      const SizedBox(width: 3),
                      Text(
                        'Lv.${LevelUtils.levelFromXp(student.totalXp)}',
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
            const Icon(Icons.chevron_right, color: darkTextSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

const _maxVisibleQuests = 5;

class _ActiveQuestList extends ConsumerStatefulWidget {
  final List<AssignedQuest> quests;
  final Map<String, String> studentNames;
  final String groupId;

  const _ActiveQuestList({
    required this.quests,
    required this.studentNames,
    required this.groupId,
  });

  @override
  ConsumerState<_ActiveQuestList> createState() => _ActiveQuestListState();
}

class _ActiveQuestListState extends ConsumerState<_ActiveQuestList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final quests = widget.quests;
    final visible =
        _showAll ? quests : quests.take(_maxVisibleQuests).toList();
    final hasMore = quests.length > _maxVisibleQuests;

    return Column(
      children: [
        ...visible.map((quest) => Column(
              children: [
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: darkDivider,
                ),
                _ActiveQuestTile(
                  quest: quest,
                  studentName:
                      widget.studentNames[quest.studentId] ?? 'Unknown',
                  onEdit: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (_) => AssignQuestDialog(
                        groupId: widget.groupId,
                        editQuest: quest,
                        editStudentName:
                            widget.studentNames[quest.studentId],
                      ),
                    );
                    if (result == true) {
                      ref.invalidate(teacherAssignedQuestsProvider);
                    }
                  },
                  onDeactivate: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF1E0E3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                              color: Colors.black, width: 5),
                        ),
                        title: Text(
                          'Remove Quest',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to remove "${quest.title}"?',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                            color: darkTextSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                                color: darkTextSecondary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
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
                    if (confirm == true) {
                      await ref
                          .read(assignedQuestServiceProvider)
                          .deactivateQuest(quest.id);
                      ref.invalidate(teacherAssignedQuestsProvider);
                    }
                  },
                ),
              ],
            )),
        if (hasMore && !_showAll)
          GestureDetector(
            onTap: () => setState(() => _showAll = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Show all ${quests.length} quests',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentCoral,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActiveQuestTile extends StatelessWidget {
  final AssignedQuest quest;
  final String studentName;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  const _ActiveQuestTile({
    required this.quest,
    required this.studentName,
    required this.onEdit,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(Icons.assignment_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$studentName · ${quest.target} sessions · +${quest.rewardXp} XP · ${quest.isRecurring ? 'Recurring Weekly' : 'One Time'}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDeactivate,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.red, size: 16),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
