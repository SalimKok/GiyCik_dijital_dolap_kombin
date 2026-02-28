import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gircik/screens/home_screen.dart';
import 'package:gircik/screens/login_screen.dart';
import 'package:gircik/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama açılışında karşılama / giriş / ana sayfa akışını yönetir.
class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  static const String _keyLoggedIn = 'isLoggedIn';

  bool? _hasSeenWelcome;
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Geliştirme (Debug) aşamasında her seferinde Welcome'dan başlamak için:
    bool seen = await WelcomeScreen.hasUserSeenWelcome();
    bool loggedIn = prefs.getBool(_keyLoggedIn) ?? false;

    if (kDebugMode) {
      seen = false;     // Welcome ekranını zorla göster
      loggedIn = false; // Login ekranını zorla göster
    }

    if (!mounted) return;
    setState(() {
      _hasSeenWelcome = seen;
      _isLoggedIn = loggedIn;
    });
  }

  Future<void> _markLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenWelcome == null || _isLoggedIn == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Yükleniyor...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // 1. Karşılama Ekranı (Eğer görülmediyse)
    if (!_hasSeenWelcome!) {
      return WelcomeScreen(
        onWelcomeDone: () {
          setState(() => _hasSeenWelcome = true);
        },
      );
    }

    // 2. Giriş Ekranı (Giriş yapılmadıysa)
    if (!_isLoggedIn!) {
      return LoginScreen(
        onLoginSuccess: () async {
          await _markLoggedIn(); // SharedPreferences'a kaydet
          setState(() => _isLoggedIn = true);
        },
      );
    }

    return const HomeScreen();
  }
}
