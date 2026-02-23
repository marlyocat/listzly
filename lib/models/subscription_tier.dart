enum SubscriptionTier {
  free,
  pro,
  teacherLite,
  teacherPro,
  teacherPremium;

  bool get isPro => this != free;
  bool get isTeacherPlan =>
      this == teacherLite || this == teacherPro || this == teacherPremium;
  bool get isFree => this == free;

  String get displayName {
    switch (this) {
      case free:
        return 'Free';
      case pro:
        return 'Pro';
      case teacherLite:
        return 'Lite';
      case teacherPro:
        return 'Pro';
      case teacherPremium:
        return 'Premium';
    }
  }

  /// Max students a teacher can have.
  int get maxStudents {
    switch (this) {
      case free:
      case pro:
        return 1;
      case teacherLite:
        return 10;
      case teacherPro:
        return 25;
      case teacherPremium:
        return 50;
    }
  }

  // Personal Pro features (available with any paid plan)
  bool get canRecord => isPro;
  bool get canUseAllInstruments => isPro;
  bool get canViewActivity => isPro;
  bool get canUseSheetMusicScanner => isPro;

  // Teacher-specific Pro features (only with teacher plans)
  bool get canAssignQuests => isTeacherPlan;
  bool get canViewStudentRecordings => isTeacherPlan;

  /// Whether students in this teacher's group should inherit Pro.
  bool get studentsInheritPro => isTeacherPlan;

  String toDbString() {
    switch (this) {
      case free:
        return 'free';
      case pro:
        return 'pro';
      case teacherLite:
        return 'teacher_lite';
      case teacherPro:
        return 'teacher_pro';
      case teacherPremium:
        return 'teacher_premium';
    }
  }

  static SubscriptionTier fromString(String value) {
    switch (value) {
      case 'teacher_premium':
        return SubscriptionTier.teacherPremium;
      case 'teacher_pro':
        return SubscriptionTier.teacherPro;
      case 'teacher_lite':
        return SubscriptionTier.teacherLite;
      case 'pro':
        return SubscriptionTier.pro;
      default:
        return SubscriptionTier.free;
    }
  }
}
