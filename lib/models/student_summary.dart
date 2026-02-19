class StudentSummary {
  final String studentId;
  final String displayName;
  final String? avatarUrl;
  final int totalXp;
  final int currentStreak;
  final DateTime joinedAt;

  const StudentSummary({
    required this.studentId,
    required this.displayName,
    this.avatarUrl,
    required this.totalXp,
    required this.currentStreak,
    required this.joinedAt,
  });
}
