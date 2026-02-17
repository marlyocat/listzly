import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:listzly/config/supabase_config.dart';
import 'package:listzly/providers/auth_provider.dart';
import 'package:listzly/pages/intro_page.dart';
import 'package:listzly/pages/home_page.dart';
import 'package:listzly/pages/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user != null ? const HomePage() : const IntroPage(),
      routes: {
        '/intropage': (context) => const IntroPage(),
        '/homepage': (context) => const HomePage(),
        '/auth': (context) => const AuthPage(),
      },
    );
  }
}
