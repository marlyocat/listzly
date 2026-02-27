import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listzly/providers/profile_provider.dart';
import 'package:listzly/pages/home_page.dart';
import 'package:listzly/pages/onboarding_page.dart';
import 'package:listzly/theme/colors.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (!profile.roleSelected) {
          return const OnboardingPage();
        }
        return const HomePage();
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF150833),
        body: Center(
          child: CircularProgressIndicator(color: primaryLight),
        ),
      ),
      error: (_, _) => const HomePage(),
    );
  }
}
