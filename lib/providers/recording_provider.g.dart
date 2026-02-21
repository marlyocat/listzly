// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recordingServiceHash() => r'ce863c2e090979e6f4b6b16b286d38f189e43610';

/// See also [recordingService].
@ProviderFor(recordingService)
final recordingServiceProvider = AutoDisposeProvider<RecordingService>.internal(
  recordingService,
  name: r'recordingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recordingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecordingServiceRef = AutoDisposeProviderRef<RecordingService>;
String _$userRecordingsHash() => r'56003af72ba9a7deaa3c60efddf153b17808aae3';

/// See also [userRecordings].
@ProviderFor(userRecordings)
final userRecordingsProvider =
    AutoDisposeFutureProvider<List<PracticeRecording>>.internal(
      userRecordings,
      name: r'userRecordingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userRecordingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRecordingsRef =
    AutoDisposeFutureProviderRef<List<PracticeRecording>>;
String _$studentRecordingsHash() => r'e99fbfd9c5bf070cbbe0c979ea0631a0ea4bff8d';

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

/// See also [studentRecordings].
@ProviderFor(studentRecordings)
const studentRecordingsProvider = StudentRecordingsFamily();

/// See also [studentRecordings].
class StudentRecordingsFamily
    extends Family<AsyncValue<List<PracticeRecording>>> {
  /// See also [studentRecordings].
  const StudentRecordingsFamily();

  /// See also [studentRecordings].
  StudentRecordingsProvider call({required String studentId}) {
    return StudentRecordingsProvider(studentId: studentId);
  }

  @override
  StudentRecordingsProvider getProviderOverride(
    covariant StudentRecordingsProvider provider,
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
  String? get name => r'studentRecordingsProvider';
}

/// See also [studentRecordings].
class StudentRecordingsProvider
    extends AutoDisposeFutureProvider<List<PracticeRecording>> {
  /// See also [studentRecordings].
  StudentRecordingsProvider({required String studentId})
    : this._internal(
        (ref) => studentRecordings(
          ref as StudentRecordingsRef,
          studentId: studentId,
        ),
        from: studentRecordingsProvider,
        name: r'studentRecordingsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentRecordingsHash,
        dependencies: StudentRecordingsFamily._dependencies,
        allTransitiveDependencies:
            StudentRecordingsFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentRecordingsProvider._internal(
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
    FutureOr<List<PracticeRecording>> Function(StudentRecordingsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentRecordingsProvider._internal(
        (ref) => create(ref as StudentRecordingsRef),
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
  AutoDisposeFutureProviderElement<List<PracticeRecording>> createElement() {
    return _StudentRecordingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentRecordingsProvider && other.studentId == studentId;
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
mixin StudentRecordingsRef
    on AutoDisposeFutureProviderRef<List<PracticeRecording>> {
  /// The parameter `studentId` of this provider.
  String get studentId;
}

class _StudentRecordingsProviderElement
    extends AutoDisposeFutureProviderElement<List<PracticeRecording>>
    with StudentRecordingsRef {
  _StudentRecordingsProviderElement(super.provider);

  @override
  String get studentId => (origin as StudentRecordingsProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
