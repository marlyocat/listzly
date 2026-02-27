// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assignedQuestService)
final assignedQuestServiceProvider = AssignedQuestServiceProvider._();

final class AssignedQuestServiceProvider
    extends
        $FunctionalProvider<
          AssignedQuestService,
          AssignedQuestService,
          AssignedQuestService
        >
    with $Provider<AssignedQuestService> {
  AssignedQuestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignedQuestServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignedQuestServiceHash();

  @$internal
  @override
  $ProviderElement<AssignedQuestService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AssignedQuestService create(Ref ref) {
    return assignedQuestService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssignedQuestService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssignedQuestService>(value),
    );
  }
}

String _$assignedQuestServiceHash() =>
    r'03e2681fa2b29c18d4e5a2cecab8b48f864df6d0';

/// For students: fetch quest progress for their assigned quests.

@ProviderFor(assignedQuestProgress)
final assignedQuestProgressProvider = AssignedQuestProgressProvider._();

/// For students: fetch quest progress for their assigned quests.

final class AssignedQuestProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuestProgress>>,
          List<QuestProgress>,
          FutureOr<List<QuestProgress>>
        >
    with
        $FutureModifier<List<QuestProgress>>,
        $FutureProvider<List<QuestProgress>> {
  /// For students: fetch quest progress for their assigned quests.
  AssignedQuestProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignedQuestProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignedQuestProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<QuestProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuestProgress>> create(Ref ref) {
    return assignedQuestProgress(ref);
  }
}

String _$assignedQuestProgressHash() =>
    r'e8694277faa88e6ce9e3415e0a1922c96fd6a2f6';

/// For students: fetch the AssignedQuest definitions (for title, icon, etc.).

@ProviderFor(assignedQuestDefinitions)
final assignedQuestDefinitionsProvider = AssignedQuestDefinitionsProvider._();

/// For students: fetch the AssignedQuest definitions (for title, icon, etc.).

final class AssignedQuestDefinitionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssignedQuest>>,
          List<AssignedQuest>,
          FutureOr<List<AssignedQuest>>
        >
    with
        $FutureModifier<List<AssignedQuest>>,
        $FutureProvider<List<AssignedQuest>> {
  /// For students: fetch the AssignedQuest definitions (for title, icon, etc.).
  AssignedQuestDefinitionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignedQuestDefinitionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignedQuestDefinitionsHash();

  @$internal
  @override
  $FutureProviderElement<List<AssignedQuest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssignedQuest>> create(Ref ref) {
    return assignedQuestDefinitions(ref);
  }
}

String _$assignedQuestDefinitionsHash() =>
    r'f4c254cc944c59974f45b8604d88f49af1e3db84';

/// For teachers: fetch active quests they've assigned to their group.

@ProviderFor(teacherAssignedQuests)
final teacherAssignedQuestsProvider = TeacherAssignedQuestsProvider._();

/// For teachers: fetch active quests they've assigned to their group.

final class TeacherAssignedQuestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AssignedQuest>>,
          List<AssignedQuest>,
          FutureOr<List<AssignedQuest>>
        >
    with
        $FutureModifier<List<AssignedQuest>>,
        $FutureProvider<List<AssignedQuest>> {
  /// For teachers: fetch active quests they've assigned to their group.
  TeacherAssignedQuestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teacherAssignedQuestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teacherAssignedQuestsHash();

  @$internal
  @override
  $FutureProviderElement<List<AssignedQuest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AssignedQuest>> create(Ref ref) {
    return teacherAssignedQuests(ref);
  }
}

String _$teacherAssignedQuestsHash() =>
    r'b2620404b44c110690335d928e22294c93329a40';
