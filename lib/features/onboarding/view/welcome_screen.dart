import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama ilk açıldığında gösterilen çok sayfalı tanıtım turu.
class WelcomeScreen extends StatefulWidget {
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
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      icon: Icons.checkroom_rounded,
      title: 'Gardıropunu\nDijitalleştir',
      subtitle:
          'Kıyafetlerini fotoğrafla, hepsini tek yerden yönet. '
          'Kategorize et, favorile, aradığını anında bul.',
      gradientColors: [Color(0xFF0D224D), Color(0xFF1A3263)], // Derin Safir
      bgIcon: Icons.dry_cleaning_rounded,
    ),
    _PageData(
      icon: Icons.auto_awesome_rounded,
      title: 'Akıllı Kombin\nÖnerileri',
      subtitle:
          'Hava durumu, özel günler ve stil tercihlerine göre '
          'yapay zeka destekli kombin önerileri al.',
      gradientColors: [Color(0xFF1A3263), Color(0xFF2B4A8E)], // Orta Safir
      bgIcon: Icons.psychology_rounded,
    ),
    _PageData(
      icon: Icons.calendar_month_rounded,
      title: 'Planla,\nRahatla',
      subtitle:
          'Stil takvimi ile etkinliklere hazırlan. '
          'Ne zaman ne giyeceğini önceden planla.',
      gradientColors: [Color(0xFF2B4A8E), Color(0xFF4D64A0)], // Açık Safir
      bgIcon: Icons.event_note_rounded,
    ),
    _PageData(
      icon: Icons.local_laundry_service_rounded,
      title: 'Hijyenini\nTakip Et',
      subtitle:
          'Kıyafetlerinin kullanım sayısını izle. '
          'Yıkama vakti gelince otomatik hatırlatma al.',
      gradientColors: [Color(0xFF4D64A0), Color(0xFF7289C4)], // Pastel Safir
      bgIcon: Icons.water_drop_rounded,
    ),
    _PageData(
      icon: Icons.explore_rounded,
      title: 'Daha Fazla\nKeşfet',
      subtitle:
          'Yapay zeka destekli seyahat asistanı ile valizini saniyeler içinde hazırla. '
          'Gelişmiş analitiklerle gardırop kullanım alışkanlıklarını incele.',
      gradientColors: [Color(0xFF7289C4), Color(0xFF9EB0E6)], // Platin/Gümüş
      bgIcon: Icons.analytics_outlined,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await WelcomeScreen.markWelcomeSeen();
    if (mounted) widget.onWelcomeDone();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Sayfa içeriği
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _OnboardingPage(data: _pages[index], theme: theme);
            },
          ),

          // Üst — Atla butonu
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: AnimatedOpacity(
              opacity: isLast ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                onPressed: isLast ? null : _finish,
                child: Text(
                  'Atla',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Alt — gösterge + buton
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nokta göstergeler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _DotIndicator(
                        isActive: index == _currentPage,
                        activeColor: Color.lerp(
                          _pages[_currentPage].gradientColors[0],
                          _pages[_currentPage].gradientColors[1],
                          0.5,
                        )!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // İleri / Başla butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: FilledButton(
                        onPressed: _nextPage,
                        style: FilledButton.styleFrom(
                          backgroundColor: Color.lerp(
                            _pages[_currentPage].gradientColors[0],
                            _pages[_currentPage].gradientColors[1],
                            0.4,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isLast ? 'Hadi Başlayalım!' : 'Devam Et'),
                            const SizedBox(width: 8),
                            Icon(
                              isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Veri Modeli ──

class _PageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData bgIcon;

  const _PageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.bgIcon,
  });
}

// ── Sayfa Widget'ı ──

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final ThemeData theme;

  const _OnboardingPage({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Üst yarı — gradient hero alanı
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.gradientColors,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan dekoratif ikonlar
                Positioned(
                  top: 60,
                  left: -20,
                  child: Icon(
                    data.bgIcon,
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: -10,
                  child: Icon(
                    data.bgIcon,
                    size: 160,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                // Ana ikon
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      data.icon,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Alt yarı — metin alanı
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 100),
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Nokta Göstergesi ──

class _DotIndicator extends StatelessWidget {
  final bool isActive;
  final Color activeColor;

  const _DotIndicator({required this.isActive, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : activeColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
