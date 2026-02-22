enum SubscriptionTier {
  free,
  pro;

  bool get isPro => this == pro;
  bool get isFree => this == free;

  String get displayName {
    switch (this) {
      case free:
        return 'Free';
      case pro:
        return 'Pro';
    }
  }

  /// Max students a teacher can have.
  int? get maxStudents {
    switch (this) {
      case free:
        return 3;
      case pro:
        return 30;
    }
  }

  bool get canRecord => isPro;
  bool get canUseAllInstruments => isPro;
  bool get canViewActivity => isPro;
  bool get canAssignQuests => isPro;
  bool get canViewStudentRecordings => isPro;
  bool get canUseSheetMusicScanner => isPro;

  static SubscriptionTier fromString(String value) {
    switch (value) {
      case 'pro':
        return SubscriptionTier.pro;
      default:
        return SubscriptionTier.free;
    }
  }
}
