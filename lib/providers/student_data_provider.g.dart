// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studentStats)
final studentStatsProvider = StudentStatsFamily._();

final class StudentStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserStats>,
          UserStats,
          FutureOr<UserStats>
        >
    with $FutureModifier<UserStats>, $FutureProvider<UserStats> {
  StudentStatsProvider._({
    required StudentStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studentStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentStatsHash();

  @override
  String toString() {
    return r'studentStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserStats> create(Ref ref) {
    final argument = this.argument as String;
    return studentStats(ref, studentId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentStatsHash() => r'014a8770688e9ac19475b38b2d2cc01897140d58';

final class StudentStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserStats>, String> {
  StudentStatsFamily._()
    : super(
        retry: null,
        name: r'studentStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudentStatsProvider call({required String studentId}) =>
      StudentStatsProvider._(argument: studentId, from: this);

  @override
  String toString() => r'studentStatsProvider';
}

@ProviderFor(studentSessions)
final studentSessionsProvider = StudentSessionsFamily._();

final class StudentSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PracticeSession>>,
          List<PracticeSession>,
          FutureOr<List<PracticeSession>>
        >
    with
        $FutureModifier<List<PracticeSession>>,
        $FutureProvider<List<PracticeSession>> {
  StudentSessionsProvider._({
    required StudentSessionsFamily super.from,
    required ({String studentId, DateTime start, DateTime end}) super.argument,
  }) : super(
         retry: null,
         name: r'studentSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentSessionsHash();

  @override
  String toString() {
    return r'studentSessionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PracticeSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PracticeSession>> create(Ref ref) {
    final argument =
        this.argument as ({String studentId, DateTime start, DateTime end});
    return studentSessions(
      ref,
      studentId: argument.studentId,
      start: argument.start,
      end: argument.end,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudentSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentSessionsHash() => r'fc66a27071d8c9c57341523050244d873a06ba5e';

final class StudentSessionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PracticeSession>>,
          ({String studentId, DateTime start, DateTime end})
        > {
  StudentSessionsFamily._()
    : super(
        retry: null,
        name: r'studentSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudentSessionsProvider call({
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) => StudentSessionsProvider._(
    argument: (studentId: studentId, start: start, end: end),
    from: this,
  );

  @override
  String toString() => r'studentSessionsProvider';
}

@ProviderFor(studentSummaryStats)
final studentSummaryStatsProvider = StudentSummaryStatsFamily._();

final class StudentSummaryStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int sessionCount, Duration totalTime})>,
          ({int sessionCount, Duration totalTime}),
          FutureOr<({int sessionCount, Duration totalTime})>
        >
    with
        $FutureModifier<({int sessionCount, Duration totalTime})>,
        $FutureProvider<({int sessionCount, Duration totalTime})> {
  StudentSummaryStatsProvider._({
    required StudentSummaryStatsFamily super.from,
    required ({String studentId, DateTime start, DateTime end}) super.argument,
  }) : super(
         retry: null,
         name: r'studentSummaryStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentSummaryStatsHash();

  @override
  String toString() {
    return r'studentSummaryStatsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({int sessionCount, Duration totalTime})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({int sessionCount, Duration totalTime})> create(Ref ref) {
    final argument =
        this.argument as ({String studentId, DateTime start, DateTime end});
    return studentSummaryStats(
      ref,
      studentId: argument.studentId,
      start: argument.start,
      end: argument.end,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudentSummaryStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentSummaryStatsHash() =>
    r'9171b051998a99fe2b7c0ea1b61e15aeb9730097';

final class StudentSummaryStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({int sessionCount, Duration totalTime})>,
          ({String studentId, DateTime start, DateTime end})
        > {
  StudentSummaryStatsFamily._()
    : super(
        retry: null,
        name: r'studentSummaryStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudentSummaryStatsProvider call({
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) => StudentSummaryStatsProvider._(
    argument: (studentId: studentId, start: start, end: end),
    from: this,
  );

  @override
  String toString() => r'studentSummaryStatsProvider';
}
