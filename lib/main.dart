import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/config/supabase_config.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/pages/intro_page.dart';
import 'package:listzly/pages/auth_gate.dart';
import 'package:listzly/pages/reset_password_page.dart';
import 'package:listzly/services/notification_service.dart';
import 'package:listzly/services/offline_session_queue.dart';
import 'package:listzly/config/revenuecat_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final navigatorKey = GlobalKey<NavigatorState>();

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

  prefsInstance = await SharedPreferences.getInstance();

  await Future.wait([
    NotificationService.instance.init(),
    Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    ).then((_) async {
      try {
        await Purchases.configure(
          PurchasesConfiguration(revenueCatApiKey),
        );
      } catch (e) {
        debugPrint('RevenueCat configure failed (offline?): $e');
      }
    }),
  ]);

  // Set RevenueCat user ID if logged in
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    try {
      await Purchases.logIn(currentUser.id);
    } catch (e) {
      debugPrint('RevenueCat logIn failed (offline?): $e');
    }
  }

  // Defer notification scheduling and offline session flush to after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _rescheduleNotifications();
    OfflineSessionQueue.flush();
  });

  // Listen for password recovery deep link before app starts
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    debugPrint('Auth event: ${data.event}');
    if (data.event == AuthChangeEvent.passwordRecovery) {
      // Small delay to ensure navigator is mounted
      Future.delayed(const Duration(milliseconds: 500), () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
      });
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _rescheduleNotifications() async {
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null) return;

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
          final lastDate =
              DateTime.parse(lastSession['completed_at'] as String);
          final daysSince = DateTime.now().difference(lastDate).inDays;
          if (daysSince < 3) {
            await NotificationService.instance
                .scheduleStreakWarnings(reminderTime);
          }
        }
      } catch (e) {
        debugPrint('Failed to schedule streak warnings: $e');
      }
    }
  } catch (e) {
    debugPrint('Failed to reschedule notifications: $e');
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: user != null ? const AuthGate() : const IntroPage(),
      ),
    );
  }
}
