// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questServiceHash() => r'b6a1ba20dc37d1a691ebeba2eca3bb13a1b545eb';

/// See also [questService].
@ProviderFor(questService)
final questServiceProvider = AutoDisposeProvider<QuestService>.internal(
  questService,
  name: r'questServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$questServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuestServiceRef = AutoDisposeProviderRef<QuestService>;
String _$dailyQuestsHash() => r'e1f26ab3d48c6cd45844876b27f0434170bfdb0f';

/// See also [dailyQuests].
@ProviderFor(dailyQuests)
final dailyQuestsProvider =
    AutoDisposeFutureProvider<List<QuestProgress>>.internal(
      dailyQuests,
      name: r'dailyQuestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dailyQuestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyQuestsRef = AutoDisposeFutureProviderRef<List<QuestProgress>>;
String _$weekCompletionStatusHash() =>
    r'f68a8f9d3ae7491de87ede8493539995b75300a5';

/// See also [weekCompletionStatus].
@ProviderFor(weekCompletionStatus)
final weekCompletionStatusProvider =
    AutoDisposeFutureProvider<List<bool>>.internal(
      weekCompletionStatus,
      name: r'weekCompletionStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weekCompletionStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeekCompletionStatusRef = AutoDisposeFutureProviderRef<List<bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
