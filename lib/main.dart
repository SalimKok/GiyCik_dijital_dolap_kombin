import 'package:flutter/material.dart';
import 'package:gircik/core/app_start_screen.dart';
import 'package:gircik/theme/app_theme.dart';
import 'package:gircik/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // To use Firebase, the user must run `flutterfire configure` and then uncomment below:
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      child: GircikApp(),
    ),
  );
}

class GircikApp extends ConsumerWidget {
  const GircikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
        title: 'GİYÇIK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppStartScreen(),
    );
  }
}
