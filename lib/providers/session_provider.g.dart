// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionServiceHash() => r'f27e17742289be6b7d4af181c3871cf3b8065588';

/// See also [sessionService].
@ProviderFor(sessionService)
final sessionServiceProvider = AutoDisposeProvider<SessionService>.internal(
  sessionService,
  name: r'sessionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionServiceRef = AutoDisposeProviderRef<SessionService>;
String _$sessionListHash() => r'50045d331267e4b4f1fc5a06af5edd42bc21fb37';

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

/// See also [sessionList].
@ProviderFor(sessionList)
const sessionListProvider = SessionListFamily();

/// See also [sessionList].
class SessionListFamily extends Family<AsyncValue<List<PracticeSession>>> {
  /// See also [sessionList].
  const SessionListFamily();

  /// See also [sessionList].
  SessionListProvider call({required DateTime start, required DateTime end}) {
    return SessionListProvider(start: start, end: end);
  }

  @override
  SessionListProvider getProviderOverride(
    covariant SessionListProvider provider,
  ) {
    return call(start: provider.start, end: provider.end);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sessionListProvider';
}

/// See also [sessionList].
class SessionListProvider
    extends AutoDisposeFutureProvider<List<PracticeSession>> {
  /// See also [sessionList].
  SessionListProvider({required DateTime start, required DateTime end})
    : this._internal(
        (ref) => sessionList(ref as SessionListRef, start: start, end: end),
        from: sessionListProvider,
        name: r'sessionListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionListHash,
        dependencies: SessionListFamily._dependencies,
        allTransitiveDependencies: SessionListFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  SessionListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<List<PracticeSession>> Function(SessionListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SessionListProvider._internal(
        (ref) => create(ref as SessionListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PracticeSession>> createElement() {
    return _SessionListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionListProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SessionListRef on AutoDisposeFutureProviderRef<List<PracticeSession>> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _SessionListProviderElement
    extends AutoDisposeFutureProviderElement<List<PracticeSession>>
    with SessionListRef {
  _SessionListProviderElement(super.provider);

  @override
  DateTime get start => (origin as SessionListProvider).start;
  @override
  DateTime get end => (origin as SessionListProvider).end;
}

String _$weeklyBarDataHash() => r'51fa3a53bcdbe9044075ffa653ce2632ea23b51d';

/// See also [weeklyBarData].
@ProviderFor(weeklyBarData)
const weeklyBarDataProvider = WeeklyBarDataFamily();

/// See also [weeklyBarData].
class WeeklyBarDataFamily extends Family<AsyncValue<Map<DateTime, int>>> {
  /// See also [weeklyBarData].
  const WeeklyBarDataFamily();

  /// See also [weeklyBarData].
  WeeklyBarDataProvider call({required DateTime weekStart}) {
    return WeeklyBarDataProvider(weekStart: weekStart);
  }

  @override
  WeeklyBarDataProvider getProviderOverride(
    covariant WeeklyBarDataProvider provider,
  ) {
    return call(weekStart: provider.weekStart);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weeklyBarDataProvider';
}

/// See also [weeklyBarData].
class WeeklyBarDataProvider
    extends AutoDisposeFutureProvider<Map<DateTime, int>> {
  /// See also [weeklyBarData].
  WeeklyBarDataProvider({required DateTime weekStart})
    : this._internal(
        (ref) => weeklyBarData(ref as WeeklyBarDataRef, weekStart: weekStart),
        from: weeklyBarDataProvider,
        name: r'weeklyBarDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weeklyBarDataHash,
        dependencies: WeeklyBarDataFamily._dependencies,
        allTransitiveDependencies:
            WeeklyBarDataFamily._allTransitiveDependencies,
        weekStart: weekStart,
      );

  WeeklyBarDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.weekStart,
  }) : super.internal();

  final DateTime weekStart;

  @override
  Override overrideWith(
    FutureOr<Map<DateTime, int>> Function(WeeklyBarDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeeklyBarDataProvider._internal(
        (ref) => create(ref as WeeklyBarDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        weekStart: weekStart,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<DateTime, int>> createElement() {
    return _WeeklyBarDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeeklyBarDataProvider && other.weekStart == weekStart;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, weekStart.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeeklyBarDataRef on AutoDisposeFutureProviderRef<Map<DateTime, int>> {
  /// The parameter `weekStart` of this provider.
  DateTime get weekStart;
}

class _WeeklyBarDataProviderElement
    extends AutoDisposeFutureProviderElement<Map<DateTime, int>>
    with WeeklyBarDataRef {
  _WeeklyBarDataProviderElement(super.provider);

  @override
  DateTime get weekStart => (origin as WeeklyBarDataProvider).weekStart;
}

String _$summaryStatsHash() => r'2212eb7963eae7d6d48a9076ac0d26377a985226';

/// See also [summaryStats].
@ProviderFor(summaryStats)
const summaryStatsProvider = SummaryStatsFamily();

/// See also [summaryStats].
class SummaryStatsFamily
    extends Family<AsyncValue<({Duration totalTime, int sessionCount})>> {
  /// See also [summaryStats].
  const SummaryStatsFamily();

  /// See also [summaryStats].
  SummaryStatsProvider call({required DateTime start, required DateTime end}) {
    return SummaryStatsProvider(start: start, end: end);
  }

  @override
  SummaryStatsProvider getProviderOverride(
    covariant SummaryStatsProvider provider,
  ) {
    return call(start: provider.start, end: provider.end);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'summaryStatsProvider';
}

/// See also [summaryStats].
class SummaryStatsProvider
    extends
        AutoDisposeFutureProvider<({Duration totalTime, int sessionCount})> {
  /// See also [summaryStats].
  SummaryStatsProvider({required DateTime start, required DateTime end})
    : this._internal(
        (ref) => summaryStats(ref as SummaryStatsRef, start: start, end: end),
        from: summaryStatsProvider,
        name: r'summaryStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$summaryStatsHash,
        dependencies: SummaryStatsFamily._dependencies,
        allTransitiveDependencies:
            SummaryStatsFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  SummaryStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<({Duration totalTime, int sessionCount})> Function(
      SummaryStatsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SummaryStatsProvider._internal(
        (ref) => create(ref as SummaryStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<({Duration totalTime, int sessionCount})>
  createElement() {
    return _SummaryStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SummaryStatsProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SummaryStatsRef
    on AutoDisposeFutureProviderRef<({Duration totalTime, int sessionCount})> {
  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _SummaryStatsProviderElement
    extends
        AutoDisposeFutureProviderElement<
          ({Duration totalTime, int sessionCount})
        >
    with SummaryStatsRef {
  _SummaryStatsProviderElement(super.provider);

  @override
  DateTime get start => (origin as SummaryStatsProvider).start;
  @override
  DateTime get end => (origin as SummaryStatsProvider).end;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
