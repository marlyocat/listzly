// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recordingService)
final recordingServiceProvider = RecordingServiceProvider._();

final class RecordingServiceProvider
    extends
        $FunctionalProvider<
          RecordingService,
          RecordingService,
          RecordingService
        >
    with $Provider<RecordingService> {
  RecordingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordingServiceHash();

  @$internal
  @override
  $ProviderElement<RecordingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecordingService create(Ref ref) {
    return recordingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordingService>(value),
    );
  }
}

String _$recordingServiceHash() => r'b054fb059b3396f77895c660b87ceb3978e0f10a';

@ProviderFor(userRecordings)
final userRecordingsProvider = UserRecordingsProvider._();

final class UserRecordingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PracticeRecording>>,
          List<PracticeRecording>,
          FutureOr<List<PracticeRecording>>
        >
    with
        $FutureModifier<List<PracticeRecording>>,
        $FutureProvider<List<PracticeRecording>> {
  UserRecordingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRecordingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRecordingsHash();

  @$internal
  @override
  $FutureProviderElement<List<PracticeRecording>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PracticeRecording>> create(Ref ref) {
    return userRecordings(ref);
  }
}

String _$userRecordingsHash() => r'5e5743c795f76e9a644a5acda6abc542e8debc0d';

@ProviderFor(studentRecordings)
final studentRecordingsProvider = StudentRecordingsFamily._();

final class StudentRecordingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PracticeRecording>>,
          List<PracticeRecording>,
          FutureOr<List<PracticeRecording>>
        >
    with
        $FutureModifier<List<PracticeRecording>>,
        $FutureProvider<List<PracticeRecording>> {
  StudentRecordingsProvider._({
    required StudentRecordingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'studentRecordingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studentRecordingsHash();

  @override
  String toString() {
    return r'studentRecordingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PracticeRecording>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PracticeRecording>> create(Ref ref) {
    final argument = this.argument as String;
    return studentRecordings(ref, studentId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentRecordingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studentRecordingsHash() => r'8ba7456454d7e85c233aed97c08ef86cf8672d3a';

final class StudentRecordingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PracticeRecording>>, String> {
  StudentRecordingsFamily._()
    : super(
        retry: null,
        name: r'studentRecordingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudentRecordingsProvider call({required String studentId}) =>
      StudentRecordingsProvider._(argument: studentId, from: this);

  @override
  String toString() => r'studentRecordingsProvider';
}
