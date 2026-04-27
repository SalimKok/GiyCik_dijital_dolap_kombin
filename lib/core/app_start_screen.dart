import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/main_layout_screen.dart';
import 'package:gircik/features/auth/view/login_screen.dart';
import 'package:gircik/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:gircik/features/onboarding/view/welcome_screen.dart';

class AppStartScreen extends ConsumerWidget {
  const AppStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final authNotifier = ref.read(authViewModelProvider.notifier);

    // 0. Yükleme Durumu
    if (authState.status == AuthStatus.initial) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'GiyÇık Yükleniyor...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // 1. Karşılama Ekranı (Eğer görülmediyse)
    if (!authState.hasSeenWelcome) {
      return WelcomeScreen(
        onWelcomeDone: () {
          authNotifier.setSeenWelcome(true);
        },
      );
    }

    // 2. Giriş Ekranı (Giriş yapılmadıysa)
    if (authState.status == AuthStatus.unauthenticated) {
      return const LoginScreen();
    }

    // 3. Ana Sayfa
    return const MainLayoutScreen();
  }
}
