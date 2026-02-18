import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/config/supabase_config.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/pages/intro_page.dart';
import 'package:listzly/pages/home_page.dart';
import 'package:listzly/pages/auth_page.dart';
import 'package:listzly/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Reschedule reminder if user is logged in and has one set
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    try {
      final result = await Supabase.instance.client
          .from('user_settings')
          .select('reminder_time')
          .eq('user_id', currentUser.id)
          .maybeSingle();
      final reminderTime = result?['reminder_time'] as String?;
      if (reminderTime != null && reminderTime.isNotEmpty) {
        await NotificationService.instance.scheduleDailyReminder(reminderTime);
      }
    } catch (_) {
      // Non-critical: if reschedule fails, user can re-set in settings
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: user != null ? const HomePage() : const IntroPage(),
        routes: {
          '/intropage': (context) => const IntroPage(),
          '/homepage': (context) => const HomePage(),
          '/auth': (context) => const AuthPage(),
        },
      ),
    );
  }
}
