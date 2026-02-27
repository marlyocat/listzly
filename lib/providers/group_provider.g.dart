// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupService)
final groupServiceProvider = GroupServiceProvider._();

final class GroupServiceProvider
    extends $FunctionalProvider<GroupService, GroupService, GroupService>
    with $Provider<GroupService> {
  GroupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupServiceHash();

  @$internal
  @override
  $ProviderElement<GroupService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupService create(Ref ref) {
    return groupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupService>(value),
    );
  }
}

String _$groupServiceHash() => r'c63246105d44797694624a0605775cc5a5bf348a';

@ProviderFor(teacherGroup)
final teacherGroupProvider = TeacherGroupProvider._();

final class TeacherGroupProvider
    extends
        $FunctionalProvider<
          AsyncValue<TeacherGroup?>,
          TeacherGroup?,
          FutureOr<TeacherGroup?>
        >
    with $FutureModifier<TeacherGroup?>, $FutureProvider<TeacherGroup?> {
  TeacherGroupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teacherGroupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teacherGroupHash();

  @$internal
  @override
  $FutureProviderElement<TeacherGroup?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TeacherGroup?> create(Ref ref) {
    return teacherGroup(ref);
  }
}

String _$teacherGroupHash() => r'550122c6a214988966260490751db4662bc8f43c';

@ProviderFor(studentMembership)
final studentMembershipProvider = StudentMembershipProvider._();

final class StudentMembershipProvider
    extends
        $FunctionalProvider<
          AsyncValue<GroupMember?>,
          GroupMember?,
          FutureOr<GroupMember?>
        >
    with $FutureModifier<GroupMember?>, $FutureProvider<GroupMember?> {
  StudentMembershipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'studentMembershipProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$studentMembershipHash();

  @$internal
  @override
  $FutureProviderElement<GroupMember?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GroupMember?> create(Ref ref) {
    return studentMembership(ref);
  }
}

String _$studentMembershipHash() => r'8e027c9836e37c411ac28fe3710250b1aba98c81';

@ProviderFor(isInGroup)
final isInGroupProvider = IsInGroupProvider._();

final class IsInGroupProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsInGroupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isInGroupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isInGroupHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isInGroup(ref);
  }
}

String _$isInGroupHash() => r'12f60570e2e06dc26e3db37ccae7b2cace157eda';

@ProviderFor(teacherStudents)
final teacherStudentsProvider = TeacherStudentsProvider._();

final class TeacherStudentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StudentSummary>>,
          List<StudentSummary>,
          FutureOr<List<StudentSummary>>
        >
    with
        $FutureModifier<List<StudentSummary>>,
        $FutureProvider<List<StudentSummary>> {
  TeacherStudentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teacherStudentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teacherStudentsHash();

  @$internal
  @override
  $FutureProviderElement<List<StudentSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StudentSummary>> create(Ref ref) {
    return teacherStudents(ref);
  }
}

String _$teacherStudentsHash() => r'8e285c3f66540e51516b94abf1b557a0ac60578f';

@ProviderFor(unreadGroupNotifications)
final unreadGroupNotificationsProvider = UnreadGroupNotificationsProvider._();

final class UnreadGroupNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupNotification>>,
          List<GroupNotification>,
          Stream<List<GroupNotification>>
        >
    with
        $FutureModifier<List<GroupNotification>>,
        $StreamProvider<List<GroupNotification>> {
  UnreadGroupNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadGroupNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadGroupNotificationsHash();

  @$internal
  @override
  $StreamProviderElement<List<GroupNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupNotification>> create(Ref ref) {
    return unreadGroupNotifications(ref);
  }
}

String _$unreadGroupNotificationsHash() =>
    r'efdd82e743f19c45b5687644123a2255c4354229';
