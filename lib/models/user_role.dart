enum UserRole {
  selfLearner,
  student,
  teacher;

  String toJson() {
    switch (this) {
      case UserRole.selfLearner:
        return 'self_learner';
      case UserRole.student:
        return 'student';
      case UserRole.teacher:
        return 'teacher';
    }
  }

  static UserRole fromJson(String value) {
    switch (value) {
      case 'self_learner':
        return UserRole.selfLearner;
      case 'student':
        return UserRole.student;
      case 'teacher':
        return UserRole.teacher;
      default:
        return UserRole.selfLearner;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.selfLearner:
        return 'Self-Learner';
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
    }
  }
}
