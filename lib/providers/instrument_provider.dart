import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/session_provider.dart';

part 'instrument_provider.g.dart';

/// Per-instrument stats for Profile page (minutes + sessions).
@riverpod
Future<List<Map<String, dynamic>>> instrumentStats(
    Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('Not authenticated');
  return ref.watch(sessionServiceProvider).getInstrumentStats(user.id);
}
