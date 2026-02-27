// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionService)
final sessionServiceProvider = SessionServiceProvider._();

final class SessionServiceProvider
    extends $FunctionalProvider<SessionService, SessionService, SessionService>
    with $Provider<SessionService> {
  SessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionServiceHash();

  @$internal
  @override
  $ProviderElement<SessionService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionService create(Ref ref) {
    return sessionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionService>(value),
    );
  }
}

String _$sessionServiceHash() => r'a4ed66d10a43ce8f4995f46a77c57f2123c617a5';

@ProviderFor(sessionList)
final sessionListProvider = SessionListFamily._();

final class SessionListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PracticeSession>>,
          List<PracticeSession>,
          FutureOr<List<PracticeSession>>
        >
    with
        $FutureModifier<List<PracticeSession>>,
        $FutureProvider<List<PracticeSession>> {
  SessionListProvider._({
    required SessionListFamily super.from,
    required ({DateTime start, DateTime end}) super.argument,
  }) : super(
         retry: null,
         name: r'sessionListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionListHash();

  @override
  String toString() {
    return r'sessionListProvider'
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
    final argument = this.argument as ({DateTime start, DateTime end});
    return sessionList(ref, start: argument.start, end: argument.end);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionListHash() => r'aa35a485d674fe1ba5fbe15e7f1b608d1df64732';

final class SessionListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PracticeSession>>,
          ({DateTime start, DateTime end})
        > {
  SessionListFamily._()
    : super(
        retry: null,
        name: r'sessionListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionListProvider call({required DateTime start, required DateTime end}) =>
      SessionListProvider._(argument: (start: start, end: end), from: this);

  @override
  String toString() => r'sessionListProvider';
}

@ProviderFor(weeklyBarData)
final weeklyBarDataProvider = WeeklyBarDataFamily._();

final class WeeklyBarDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DateTime, int>>,
          Map<DateTime, int>,
          FutureOr<Map<DateTime, int>>
        >
    with
        $FutureModifier<Map<DateTime, int>>,
        $FutureProvider<Map<DateTime, int>> {
  WeeklyBarDataProvider._({
    required WeeklyBarDataFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'weeklyBarDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weeklyBarDataHash();

  @override
  String toString() {
    return r'weeklyBarDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<DateTime, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<DateTime, int>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return weeklyBarData(ref, weekStart: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyBarDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weeklyBarDataHash() => r'90b6dd23fe18d8837c20b4eff5520dbf625cb053';

final class WeeklyBarDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<DateTime, int>>, DateTime> {
  WeeklyBarDataFamily._()
    : super(
        retry: null,
        name: r'weeklyBarDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeeklyBarDataProvider call({required DateTime weekStart}) =>
      WeeklyBarDataProvider._(argument: weekStart, from: this);

  @override
  String toString() => r'weeklyBarDataProvider';
}

@ProviderFor(summaryStats)
final summaryStatsProvider = SummaryStatsFamily._();

final class SummaryStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int sessionCount, Duration totalTime})>,
          ({int sessionCount, Duration totalTime}),
          FutureOr<({int sessionCount, Duration totalTime})>
        >
    with
        $FutureModifier<({int sessionCount, Duration totalTime})>,
        $FutureProvider<({int sessionCount, Duration totalTime})> {
  SummaryStatsProvider._({
    required SummaryStatsFamily super.from,
    required ({DateTime start, DateTime end}) super.argument,
  }) : super(
         retry: null,
         name: r'summaryStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$summaryStatsHash();

  @override
  String toString() {
    return r'summaryStatsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({int sessionCount, Duration totalTime})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({int sessionCount, Duration totalTime})> create(Ref ref) {
    final argument = this.argument as ({DateTime start, DateTime end});
    return summaryStats(ref, start: argument.start, end: argument.end);
  }

  @override
  bool operator ==(Object other) {
    return other is SummaryStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$summaryStatsHash() => r'e21f0d2b63eb6bf1d9187a582d7f9548d30f27b1';

final class SummaryStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({int sessionCount, Duration totalTime})>,
          ({DateTime start, DateTime end})
        > {
  SummaryStatsFamily._()
    : super(
        retry: null,
        name: r'summaryStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SummaryStatsProvider call({required DateTime start, required DateTime end}) =>
      SummaryStatsProvider._(argument: (start: start, end: end), from: this);

  @override
  String toString() => r'summaryStatsProvider';
}
