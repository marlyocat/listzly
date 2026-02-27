// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questService)
final questServiceProvider = QuestServiceProvider._();

final class QuestServiceProvider
    extends $FunctionalProvider<QuestService, QuestService, QuestService>
    with $Provider<QuestService> {
  QuestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questServiceHash();

  @$internal
  @override
  $ProviderElement<QuestService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QuestService create(Ref ref) {
    return questService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestService>(value),
    );
  }
}

String _$questServiceHash() => r'274e8ebdf7184f6f57c491102a31e8f429698dcd';

@ProviderFor(dailyQuests)
final dailyQuestsProvider = DailyQuestsProvider._();

final class DailyQuestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuestProgress>>,
          List<QuestProgress>,
          FutureOr<List<QuestProgress>>
        >
    with
        $FutureModifier<List<QuestProgress>>,
        $FutureProvider<List<QuestProgress>> {
  DailyQuestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyQuestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyQuestsHash();

  @$internal
  @override
  $FutureProviderElement<List<QuestProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuestProgress>> create(Ref ref) {
    return dailyQuests(ref);
  }
}

String _$dailyQuestsHash() => r'5f56cff3c343f41f24d87dd901c039db6eba7f54';

@ProviderFor(weekCompletionStatus)
final weekCompletionStatusProvider = WeekCompletionStatusProvider._();

final class WeekCompletionStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<bool>>,
          List<bool>,
          FutureOr<List<bool>>
        >
    with $FutureModifier<List<bool>>, $FutureProvider<List<bool>> {
  WeekCompletionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weekCompletionStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weekCompletionStatusHash();

  @$internal
  @override
  $FutureProviderElement<List<bool>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<bool>> create(Ref ref) {
    return weekCompletionStatus(ref);
  }
}

String _$weekCompletionStatusHash() =>
    r'0e62d09b48633505a37b2d80b9fb6aebd5cb27cd';
