import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/config/supabase_config.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/pages/intro_page.dart';
import 'package:listzly/pages/home_page.dart';
import 'package:listzly/pages/auth_page.dart';
import 'package:listzly/pages/auth_gate.dart';
import 'package:listzly/services/notification_service.dart';
import 'package:listzly/config/revenuecat_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock phones to portrait; let tablets rotate freely
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide =
      view.physicalSize.shortestSide / view.devicePixelRatio;
  if (shortestSide < 600) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  await NotificationService.instance.init();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Initialize RevenueCat
  await Purchases.configure(
    PurchasesConfiguration(revenueCatApiKey),
  );

  // Reschedule reminder if user is logged in and has one set
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    // Set RevenueCat user ID to match Supabase auth
    await Purchases.logIn(currentUser.id);
    try {
      final result = await Supabase.instance.client
          .from('user_settings')
          .select('reminder_time')
          .eq('user_id', currentUser.id)
          .maybeSingle();
      final reminderTime = result?['reminder_time'] as String?;
      if (reminderTime != null && reminderTime.isNotEmpty) {
        await NotificationService.instance.scheduleDailyReminder(reminderTime);

        // Reschedule streak warnings based on last practice date
        try {
          final lastSession = await Supabase.instance.client
              .from('practice_sessions')
              .select('completed_at')
              .eq('user_id', currentUser.id)
              .order('completed_at', ascending: false)
              .limit(1)
              .maybeSingle();
          if (lastSession != null) {
            final lastDate = DateTime.parse(lastSession['completed_at'] as String);
            final daysSince = DateTime.now().difference(lastDate).inDays;
            // Only schedule if last practice was recent (within grace period)
            if (daysSince < 3) {
              await NotificationService.instance.scheduleStreakWarnings(reminderTime);
            }
          }
        } catch (e) {
          debugPrint('Failed to schedule streak warnings: $e');
        }
      }
    } catch (e) {
      // Non-critical: if reschedule fails, user can re-set in settings
      debugPrint('Failed to reschedule notifications: $e');
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
        home: user != null ? const AuthGate() : const IntroPage(),
        routes: {
          '/intropage': (context) => const IntroPage(),
          '/homepage': (context) => const HomePage(),
          '/auth': (context) => const AuthPage(),
        },
      ),
    );
  }
}
