// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignedQuestServiceHash() =>
    r'b20ceac5828722dbbeeab17b47e1832c30c12778';

/// See also [assignedQuestService].
@ProviderFor(assignedQuestService)
final assignedQuestServiceProvider =
    AutoDisposeProvider<AssignedQuestService>.internal(
      assignedQuestService,
      name: r'assignedQuestServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignedQuestServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssignedQuestServiceRef = AutoDisposeProviderRef<AssignedQuestService>;
String _$assignedQuestProgressHash() =>
    r'ee563d9c9b2ce2b2aa9ccceb6ef6a2aeff9c3f04';

/// For students: fetch quest progress for their assigned quests.
///
/// Copied from [assignedQuestProgress].
@ProviderFor(assignedQuestProgress)
final assignedQuestProgressProvider =
    AutoDisposeFutureProvider<List<QuestProgress>>.internal(
      assignedQuestProgress,
      name: r'assignedQuestProgressProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignedQuestProgressHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssignedQuestProgressRef =
    AutoDisposeFutureProviderRef<List<QuestProgress>>;
String _$assignedQuestDefinitionsHash() =>
    r'b3b7d5eaf77d2c011941773020408949fa3b936b';

/// For students: fetch the AssignedQuest definitions (for title, icon, etc.).
///
/// Copied from [assignedQuestDefinitions].
@ProviderFor(assignedQuestDefinitions)
final assignedQuestDefinitionsProvider =
    AutoDisposeFutureProvider<List<AssignedQuest>>.internal(
      assignedQuestDefinitions,
      name: r'assignedQuestDefinitionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignedQuestDefinitionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssignedQuestDefinitionsRef =
    AutoDisposeFutureProviderRef<List<AssignedQuest>>;
String _$teacherAssignedQuestsHash() =>
    r'e9fd277cdda3644eec186ba5c5ab21992c485592';

/// For teachers: fetch active quests they've assigned to their group.
///
/// Copied from [teacherAssignedQuests].
@ProviderFor(teacherAssignedQuests)
final teacherAssignedQuestsProvider =
    AutoDisposeFutureProvider<List<AssignedQuest>>.internal(
      teacherAssignedQuests,
      name: r'teacherAssignedQuestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherAssignedQuestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherAssignedQuestsRef =
    AutoDisposeFutureProviderRef<List<AssignedQuest>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
