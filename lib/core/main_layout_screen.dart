import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/home/view/home_screen.dart';
import 'package:gircik/features/wardrobe/view/wardrobe_screen.dart';
import 'package:gircik/features/outfits/view/outfits_screen.dart';
import 'package:gircik/features/style_calendar/view/style_calendar_screen.dart';
import 'package:gircik/features/laundry/view/laundry_screen.dart';
import 'package:gircik/features/settings/view/settings_screen.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';
import 'package:gircik/core/providers/navigation_provider.dart';
import 'package:gircik/features/pro_features/view/pro_features_hub_screen.dart';
class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WardrobeScreen(),
    const OutfitsScreen(),
    const StyleCalendarScreen(),
    const ProFeaturesHubScreen(),
    const LaundryScreen(),
  ];

  static const List<String> _titles = [
    'GiyÇık',
    'Gardırop',
    'Kombinler',
    'Stil Takvimi',
    'Pro Özellikler',
    'Hijyen & Yıkama',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscription = ref.watch(subscriptionProvider);
    final currentIndex = ref.watch(mainNavIndexProvider);
    final isHome = currentIndex == 0;

    // Sync external changes to local state
    if (_currentIndex != currentIndex) {
      _currentIndex = currentIndex;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
        leading: isHome
            ? Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: subscription.isPro
                          ? LinearGradient(
                              colors: [Colors.amber.shade600, Colors.orange.shade700],
                            )
                          : null,
                      color: subscription.isPro ? null : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          subscription.isPro ? Icons.workspace_premium_rounded : Icons.person_rounded,
                          size: 16,
                          color: subscription.isPro ? Colors.white : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subscription.isPro ? 'PRO' : 'Ücretsiz',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: subscription.isPro ? Colors.white : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        leadingWidth: isHome ? 110 : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == 4) { // Pro Özellikler indexi
            final isPro = ref.read(subscriptionProvider).isPro;
            if (!isPro) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pro özellikler sadece Pro üyelere özeldir.')));
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProPaywallScreen()));
              return;
            }
          }
          setState(() {
            _currentIndex = index;
          });
          ref.read(mainNavIndexProvider.notifier).navigate(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom_rounded),
            label: 'Gardırop',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Kombin',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Takvim',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium_rounded),
            label: 'Pro',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_laundry_service_outlined),
            selectedIcon: Icon(Icons.local_laundry_service_rounded),
            label: 'Hijyen',
          ),
        ],
      ),
    );
  }
}
