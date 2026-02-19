// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupServiceHash() => r'45c0d9b9e3edeec12e239a085203bb9f37c54098';

/// See also [groupService].
@ProviderFor(groupService)
final groupServiceProvider = AutoDisposeProvider<GroupService>.internal(
  groupService,
  name: r'groupServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupServiceRef = AutoDisposeProviderRef<GroupService>;
String _$teacherGroupHash() => r'6d0377d91f5cf85a0a527334b1b6b860254dc360';

/// See also [teacherGroup].
@ProviderFor(teacherGroup)
final teacherGroupProvider = AutoDisposeFutureProvider<TeacherGroup?>.internal(
  teacherGroup,
  name: r'teacherGroupProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$teacherGroupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherGroupRef = AutoDisposeFutureProviderRef<TeacherGroup?>;
String _$studentMembershipHash() => r'fc77e76f7516e7d462c783654c35ccdd41be24e9';

/// See also [studentMembership].
@ProviderFor(studentMembership)
final studentMembershipProvider =
    AutoDisposeFutureProvider<GroupMember?>.internal(
      studentMembership,
      name: r'studentMembershipProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentMembershipHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentMembershipRef = AutoDisposeFutureProviderRef<GroupMember?>;
String _$isInGroupHash() => r'9a50e760c77c8234f5fe10adcd5f6264568712ea';

/// See also [isInGroup].
@ProviderFor(isInGroup)
final isInGroupProvider = AutoDisposeFutureProvider<bool>.internal(
  isInGroup,
  name: r'isInGroupProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isInGroupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsInGroupRef = AutoDisposeFutureProviderRef<bool>;
String _$teacherStudentsHash() => r'870b3577069de7596fd28c7448e752b0fa1a5928';

/// See also [teacherStudents].
@ProviderFor(teacherStudents)
final teacherStudentsProvider =
    AutoDisposeFutureProvider<List<StudentSummary>>.internal(
      teacherStudents,
      name: r'teacherStudentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherStudentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherStudentsRef = AutoDisposeFutureProviderRef<List<StudentSummary>>;
String _$unreadGroupNotificationsHash() =>
    r'cfdf64fe972ab92abcb9c6610bf4eac5cdec8859';

/// See also [unreadGroupNotifications].
@ProviderFor(unreadGroupNotifications)
final unreadGroupNotificationsProvider =
    AutoDisposeStreamProvider<List<GroupNotification>>.internal(
      unreadGroupNotifications,
      name: r'unreadGroupNotificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unreadGroupNotificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadGroupNotificationsRef =
    AutoDisposeStreamProviderRef<List<GroupNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
