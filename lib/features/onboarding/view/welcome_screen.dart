import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama ilk açıldığında gösterilen karşılama (onboarding) ekranı.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onWelcomeDone,
  });

  final VoidCallback onWelcomeDone;

  static const String _keySeen = 'hasSeenWelcome';

  static Future<bool> hasUserSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeen) ?? false;
  }

  static Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeen, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _LogoSection(theme: theme),
              const SizedBox(height: 48),
              Expanded(
                child: PageView(
                  children: [
                    _OnboardingPage(
                      icon: Icons.checkroom_rounded,
                      title: 'Gardıropunu Dijitalleştir',
                      subtitle:
                          'Kıyafetlerini fotoğrafla, hepsini tek yerden yönet. '
                          'Kategorize et, favorile, aradığını anında bul.',
                    ),
                    _OnboardingPage(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Akıllı Kombin Önerileri',
                      subtitle:
                          'Hava durumu, özel günler ve stil tercihlerine göre '
                          'yapay zeka destekli kombin önerileri al.',
                    ),
                    _OnboardingPage(
                      icon: Icons.event_note_rounded,
                      title: 'Planla, Rahatla',
                      subtitle:
                          'Stil takvimi ile etkinliklere hazırlan. '
                          'Yıkama uyarıları ile hijyenini takip et.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await markWelcomeSeen();
                    if (context.mounted) onWelcomeDone();
                  },
                  child: const Text('Başla'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.checkroom_rounded,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'GiyÇık',
          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          'Kişisel gardırop ve stil asistanın',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, size: 44, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}
