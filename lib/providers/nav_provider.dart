import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_provider.g.dart';

/// Tracks the currently selected bottom navigation tab index.
@Riverpod(keepAlive: true)
class NavIndex extends _$NavIndex {
  @override
  int build() => 0;

  void set(int index) => state = index;
}
