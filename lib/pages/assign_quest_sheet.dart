import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/models/assigned_quest.dart';
import 'package:listzly/models/student_summary.dart';
import 'package:listzly/providers/assigned_quest_provider.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/group_provider.dart';
import 'package:listzly/theme/colors.dart';

/// Steps in the assign quest flow.
enum _Step { selectStudent, customise }

/// Centered dialog for teachers to assign quests to individual students.
class AssignQuestDialog extends ConsumerStatefulWidget {
  final String groupId;
  final AssignedQuest? editQuest;
  final String? editStudentName;

  const AssignQuestDialog({
    super.key,
    required this.groupId,
    this.editQuest,
    this.editStudentName,
  });

  @override
  ConsumerState<AssignQuestDialog> createState() => _AssignQuestDialogState();
}

class _AssignQuestDialogState extends ConsumerState<AssignQuestDialog> {
  late _Step _step;
  StudentSummary? _selectedStudent;
  bool _isSaving = false;
  bool _isRecurring = false;

  bool get _isEditing => widget.editQuest != null;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _rewardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final quest = widget.editQuest;
    if (quest != null) {
      _step = _Step.customise;
      _titleController.text = quest.title;
      _descriptionController.text = quest.description;
      _targetController.text = quest.target.toString();
      _rewardController.text = quest.rewardXp.toString();
      _isRecurring = quest.isRecurring;
    } else {
      _step = _Step.selectStudent;
      _targetController.text = '1';
      _rewardController.text = '10';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  void _pickStudent(StudentSummary student) {
    setState(() {
      _selectedStudent = student;
      _step = _Step.customise;
    });
  }

  void _goBack() {
    setState(() {
      _step = _Step.selectStudent;
      _selectedStudent = null;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: accentCoralDark,
        ),
      );
  }

  Future<void> _saveQuest() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (!_isEditing && _selectedStudent == null) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final target = int.tryParse(_targetController.text);
    final rewardXp = int.tryParse(_rewardController.text);

    if (title.isEmpty || description.isEmpty || target == null || target <= 0 || rewardXp == null || rewardXp <= 0) {
      _showError('Please fill out all fields');
      return;
    }

    if (target > 3) {
      _showError('Sessions cannot exceed 3');
      return;
    }

    if (rewardXp > 100) {
      _showError('Reward XP cannot exceed 100');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = ref.read(assignedQuestServiceProvider);

      if (_isEditing) {
        await service.updateQuest(
          questId: widget.editQuest!.id,
          title: title,
          description: description,
          target: target,
          rewardXp: rewardXp,
          isRecurring: _isRecurring,
        );
      } else {
        final now = DateTime.now().millisecondsSinceEpoch;
        await service.createQuest(
          groupId: widget.groupId,
          teacherId: user.id,
          studentId: _selectedStudent!.studentId,
          questKey: 'custom_$now',
          title: title,
          description: description,
          target: target,
          rewardXp: rewardXp,
          iconName: 'assignment_rounded',
          isRecurring: _isRecurring,
        );
      }

      ref.invalidate(teacherAssignedQuestsProvider);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        _showError(
          e.toString().contains('active quests')
              ? 'This student already has 3 active quests.'
              : 'Failed to assign quest',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E0E3D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black, width: 5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  if (_step != _Step.selectStudent && !_isEditing)
                    GestureDetector(
                      onTap: _goBack,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      _step == _Step.selectStudent
                          ? 'Select Student'
                          : _isEditing
                              ? 'Edit Quest'
                              : 'Create Quest',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: darkTextMuted, size: 20),
                  ),
                ],
              ),
              // Student chip when past step 1
              if (_step != _Step.selectStudent) ...[
                () {
                  final name = _isEditing
                      ? widget.editStudentName ?? 'Student'
                      : _selectedStudent?.displayName ?? '';
                  if (name.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_rounded,
                              color: primaryLight, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }(),
              ],
              const SizedBox(height: 16),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  child: _step == _Step.selectStudent
                      ? _buildStudentPicker()
                      : _buildCustomiseForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Step 1: Student picker ──────────────────────────────

  Widget _buildStudentPicker() {
    final studentsAsync = ref.watch(teacherStudentsProvider);

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'No students in your group yet.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkTextSecondary,
              ),
            ),
          );
        }
        return Column(
          children: students
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => _pickStudent(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        decoration: BoxDecoration(
                          color: darkCardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: darkSurfaceBg,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  s.displayName.isNotEmpty
                                      ? s.displayName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.displayName,
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: darkTextSecondary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child:
              CircularProgressIndicator(color: accentCoral, strokeWidth: 2.5),
        ),
      ),
      error: (_, _) => Text(
        'Could not load students.',
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextMuted,
        ),
      ),
    );
  }

  // ─── Step 2: Custom quest form ─────────────────────────────

  Widget _buildCustomiseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: '* Title',
          controller: _titleController,
          hint: 'e.g. Practice scales',
        ),
        const SizedBox(height: 10),
        _buildTextField(
          label: '* Description',
          controller: _descriptionController,
          hint: 'e.g. Practice all major scales',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: '* Sessions',
                controller: _targetController,
                hint: '1',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: '* Reward XP',
                controller: _rewardController,
                hint: '10',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Frequency dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '* Frequency',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: darkTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            PopupMenuButton<bool>(
              initialValue: _isRecurring,
              color: const Color(0xFF1E0E3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black, width: 3),
              ),
              position: PopupMenuPosition.under,
              onSelected: (value) => setState(() => _isRecurring = value),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: false,
                  child: Text('One Time',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
                PopupMenuItem(
                  value: true,
                  child: Row(
                    children: [
                      const Icon(Icons.repeat_rounded,
                          size: 18, color: accentCoral),
                      const SizedBox(width: 8),
                      Text('Recurring Weekly',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: darkCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isRecurring ? 'Recurring Weekly' : 'One Time',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: darkTextSecondary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveQuest,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.black, width: 3),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    _isEditing
                        ? 'Save Changes'
                        : 'Assign to ${_selectedStudent?.displayName ?? 'Student'}',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: darkTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkTextMuted.withValues(alpha: 0.4),
            ),
            isDense: true,
            filled: true,
            fillColor: darkCardBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accentCoral, width: 3),
            ),
          ),
        ),
      ],
    );
  }
}
