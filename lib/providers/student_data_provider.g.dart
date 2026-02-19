// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentStatsHash() => r'4d76b3970024b4098008eee341b31d609d950c90';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [studentStats].
@ProviderFor(studentStats)
const studentStatsProvider = StudentStatsFamily();

/// See also [studentStats].
class StudentStatsFamily extends Family<AsyncValue<UserStats>> {
  /// See also [studentStats].
  const StudentStatsFamily();

  /// See also [studentStats].
  StudentStatsProvider call({required String studentId}) {
    return StudentStatsProvider(studentId: studentId);
  }

  @override
  StudentStatsProvider getProviderOverride(
    covariant StudentStatsProvider provider,
  ) {
    return call(studentId: provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentStatsProvider';
}

/// See also [studentStats].
class StudentStatsProvider extends AutoDisposeFutureProvider<UserStats> {
  /// See also [studentStats].
  StudentStatsProvider({required String studentId})
    : this._internal(
        (ref) => studentStats(ref as StudentStatsRef, studentId: studentId),
        from: studentStatsProvider,
        name: r'studentStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentStatsHash,
        dependencies: StudentStatsFamily._dependencies,
        allTransitiveDependencies:
            StudentStatsFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final String studentId;

  @override
  Override overrideWith(
    FutureOr<UserStats> Function(StudentStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentStatsProvider._internal(
        (ref) => create(ref as StudentStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserStats> createElement() {
    return _StudentStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentStatsProvider && other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentStatsRef on AutoDisposeFutureProviderRef<UserStats> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _StudentStatsProviderElement
    extends AutoDisposeFutureProviderElement<UserStats>
    with StudentStatsRef {
  _StudentStatsProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentStatsProvider).studentId;
}

String _$studentSessionsHash() => r'dc5ecdbe6e1cd68baebb0835f52afd4dfa09623d';

/// See also [studentSessions].
@ProviderFor(studentSessions)
const studentSessionsProvider = StudentSessionsFamily();

/// See also [studentSessions].
class StudentSessionsFamily extends Family<AsyncValue<List<PracticeSession>>> {
  /// See also [studentSessions].
  const StudentSessionsFamily();

  /// See also [studentSessions].
  StudentSessionsProvider call({
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) {
    return StudentSessionsProvider(
      studentId: studentId,
      start: start,
      end: end,
    );
  }

  @override
  StudentSessionsProvider getProviderOverride(
    covariant StudentSessionsProvider provider,
  ) {
    return call(
      studentId: provider.studentId,
      start: provider.start,
      end: provider.end,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentSessionsProvider';
}

/// See also [studentSessions].
class StudentSessionsProvider
    extends AutoDisposeFutureProvider<List<PracticeSession>> {
  /// See also [studentSessions].
  StudentSessionsProvider({
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) : this._internal(
         (ref) => studentSessions(
           ref as StudentSessionsRef,
           studentId: studentId,
           start: start,
           end: end,
         ),
         from: studentSessionsProvider,
         name: r'studentSessionsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$studentSessionsHash,
         dependencies: StudentSessionsFamily._dependencies,
         allTransitiveDependencies:
             StudentSessionsFamily._allTransitiveDependencies,
         studentId: studentId,
         start: start,
         end: end,
       );

  StudentSessionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.start,
    required this.end,
  }) : super.internal();

  final String studentId;
  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<List<PracticeSession>> Function(StudentSessionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentSessionsProvider._internal(
        (ref) => create(ref as StudentSessionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PracticeSession>> createElement() {
    return _StudentSessionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentSessionsProvider &&
        other.studentId == studentId &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentSessionsRef
    on AutoDisposeFutureProviderRef<List<PracticeSession>> {
  /// The parameter `studentId` of this provider.
  String get studentId;

  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _StudentSessionsProviderElement
    extends AutoDisposeFutureProviderElement<List<PracticeSession>>
    with StudentSessionsRef {
  _StudentSessionsProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentSessionsProvider).studentId;
  @override
  DateTime get start => (origin as StudentSessionsProvider).start;
  @override
  DateTime get end => (origin as StudentSessionsProvider).end;
}

String _$studentWeeklyBarDataHash() =>
    r'91b46d596b4a3bf41ad52f2972d9a0fc6fba2c3b';

/// See also [studentWeeklyBarData].
@ProviderFor(studentWeeklyBarData)
const studentWeeklyBarDataProvider = StudentWeeklyBarDataFamily();

/// See also [studentWeeklyBarData].
class StudentWeeklyBarDataFamily
    extends Family<AsyncValue<Map<DateTime, int>>> {
  /// See also [studentWeeklyBarData].
  const StudentWeeklyBarDataFamily();

  /// See also [studentWeeklyBarData].
  StudentWeeklyBarDataProvider call({
    required String studentId,
    required DateTime weekStart,
  }) {
    return StudentWeeklyBarDataProvider(
      studentId: studentId,
      weekStart: weekStart,
    );
  }

  @override
  StudentWeeklyBarDataProvider getProviderOverride(
    covariant StudentWeeklyBarDataProvider provider,
  ) {
    return call(studentId: provider.studentId, weekStart: provider.weekStart);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentWeeklyBarDataProvider';
}

/// See also [studentWeeklyBarData].
class StudentWeeklyBarDataProvider
    extends AutoDisposeFutureProvider<Map<DateTime, int>> {
  /// See also [studentWeeklyBarData].
  StudentWeeklyBarDataProvider({
    required String studentId,
    required DateTime weekStart,
  }) : this._internal(
         (ref) => studentWeeklyBarData(
           ref as StudentWeeklyBarDataRef,
           studentId: studentId,
           weekStart: weekStart,
         ),
         from: studentWeeklyBarDataProvider,
         name: r'studentWeeklyBarDataProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$studentWeeklyBarDataHash,
         dependencies: StudentWeeklyBarDataFamily._dependencies,
         allTransitiveDependencies:
             StudentWeeklyBarDataFamily._allTransitiveDependencies,
         studentId: studentId,
         weekStart: weekStart,
       );

  StudentWeeklyBarDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.weekStart,
  }) : super.internal();

  final String studentId;
  final DateTime weekStart;

  @override
  Override overrideWith(
    FutureOr<Map<DateTime, int>> Function(StudentWeeklyBarDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentWeeklyBarDataProvider._internal(
        (ref) => create(ref as StudentWeeklyBarDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        weekStart: weekStart,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<DateTime, int>> createElement() {
    return _StudentWeeklyBarDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentWeeklyBarDataProvider &&
        other.studentId == studentId &&
        other.weekStart == weekStart;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, weekStart.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentWeeklyBarDataRef
    on AutoDisposeFutureProviderRef<Map<DateTime, int>> {
  /// The parameter `studentId` of this provider.
  String get studentId;

  /// The parameter `weekStart` of this provider.
  DateTime get weekStart;
}

class _StudentWeeklyBarDataProviderElement
    extends AutoDisposeFutureProviderElement<Map<DateTime, int>>
    with StudentWeeklyBarDataRef {
  _StudentWeeklyBarDataProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentWeeklyBarDataProvider).studentId;
  @override
  DateTime get weekStart => (origin as StudentWeeklyBarDataProvider).weekStart;
}

String _$studentSummaryStatsHash() =>
    r'45a74edb8e3c27ed0616147c4464e240fc4acafb';

/// See also [studentSummaryStats].
@ProviderFor(studentSummaryStats)
const studentSummaryStatsProvider = StudentSummaryStatsFamily();

/// See also [studentSummaryStats].
class StudentSummaryStatsFamily
    extends Family<AsyncValue<({Duration totalTime, int sessionCount})>> {
  /// See also [studentSummaryStats].
  const StudentSummaryStatsFamily();

  /// See also [studentSummaryStats].
  StudentSummaryStatsProvider call({
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) {
    return StudentSummaryStatsProvider(
      studentId: studentId,
      start: start,
      end: end,
    );
  }

  @override
  StudentSummaryStatsProvider getProviderOverride(
    covariant StudentSummaryStatsProvider provider,
  ) {
    return call(
      studentId: provider.studentId,
      start: provider.start,
      end: provider.end,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentSummaryStatsProvider';
}

/// See also [studentSummaryStats].
class StudentSummaryStatsProvider
    extends
        AutoDisposeFutureProvider<({Duration totalTime, int sessionCount})> {
  /// See also [studentSummaryStats].
  StudentSummaryStatsProvider({
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) : this._internal(
         (ref) => studentSummaryStats(
           ref as StudentSummaryStatsRef,
           studentId: studentId,
           start: start,
           end: end,
         ),
         from: studentSummaryStatsProvider,
         name: r'studentSummaryStatsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$studentSummaryStatsHash,
         dependencies: StudentSummaryStatsFamily._dependencies,
         allTransitiveDependencies:
             StudentSummaryStatsFamily._allTransitiveDependencies,
         studentId: studentId,
         start: start,
         end: end,
       );

  StudentSummaryStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
    required this.start,
    required this.end,
  }) : super.internal();

  final String studentId;
  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<({Duration totalTime, int sessionCount})> Function(
      StudentSummaryStatsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentSummaryStatsProvider._internal(
        (ref) => create(ref as StudentSummaryStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<({Duration totalTime, int sessionCount})>
  createElement() {
    return _StudentSummaryStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentSummaryStatsProvider &&
        other.studentId == studentId &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentSummaryStatsRef
    on AutoDisposeFutureProviderRef<({Duration totalTime, int sessionCount})> {
  /// The parameter `studentId` of this provider.
  String get studentId;

  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _StudentSummaryStatsProviderElement
    extends
        AutoDisposeFutureProviderElement<
          ({Duration totalTime, int sessionCount})
        >
    with StudentSummaryStatsRef {
  _StudentSummaryStatsProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentSummaryStatsProvider).studentId;
  @override
  DateTime get start => (origin as StudentSummaryStatsProvider).start;
  @override
  DateTime get end => (origin as StudentSummaryStatsProvider).end;
}

String _$studentInstrumentStatsHash() =>
    r'8774c059baddea2a1b5b12ad9a65ea7530f4ea20';

/// See also [studentInstrumentStats].
@ProviderFor(studentInstrumentStats)
const studentInstrumentStatsProvider = StudentInstrumentStatsFamily();

/// See also [studentInstrumentStats].
class StudentInstrumentStatsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [studentInstrumentStats].
  const StudentInstrumentStatsFamily();

  /// See also [studentInstrumentStats].
  StudentInstrumentStatsProvider call({required String studentId}) {
    return StudentInstrumentStatsProvider(studentId: studentId);
  }

  @override
  StudentInstrumentStatsProvider getProviderOverride(
    covariant StudentInstrumentStatsProvider provider,
  ) {
    return call(studentId: provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentInstrumentStatsProvider';
}

/// See also [studentInstrumentStats].
class StudentInstrumentStatsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [studentInstrumentStats].
  StudentInstrumentStatsProvider({required String studentId})
    : this._internal(
        (ref) => studentInstrumentStats(
          ref as StudentInstrumentStatsRef,
          studentId: studentId,
        ),
        from: studentInstrumentStatsProvider,
        name: r'studentInstrumentStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentInstrumentStatsHash,
        dependencies: StudentInstrumentStatsFamily._dependencies,
        allTransitiveDependencies:
            StudentInstrumentStatsFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentInstrumentStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final String studentId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      StudentInstrumentStatsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentInstrumentStatsProvider._internal(
        (ref) => create(ref as StudentInstrumentStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _StudentInstrumentStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentInstrumentStatsProvider &&
        other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentInstrumentStatsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _StudentInstrumentStatsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with StudentInstrumentStatsRef {
  _StudentInstrumentStatsProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentInstrumentStatsProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
