import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/features/subscription/view/pro_paywall_screen.dart';
import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/home/view/widgets/recommendation_preview.dart';

class TodayWeatherCard extends ConsumerWidget {
  final HomeState state;

  const TodayWeatherCard({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weather = state.weather;
    final recommendation = state.dailyRecommendation;
    final wardrobeItems = ref.watch(wardrobeViewModelProvider).items;

    if (weather == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        height: 160,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hava durumu ve konum güncelleniyor...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    IconData weatherIcon = Icons.wb_sunny_rounded;
    Color weatherColor = theme.colorScheme.primary;

    if (weather.condition == 'Yağmurlu') {
      weatherIcon = Icons.umbrella_rounded;
      weatherColor = theme.colorScheme.onSurfaceVariant;
    } else if (weather.condition == 'Bulutlu') {
      weatherIcon = Icons.cloud_rounded;
      weatherColor = theme.colorScheme.onSurfaceVariant;
    } else if (weather.condition == 'Karlı') {
      weatherIcon = Icons.ac_unit_rounded;
      weatherColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: weatherColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(weatherIcon, color: weatherColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.city,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${weather.temperature.toInt()}°',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w300,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather.advice,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          
          if (recommendation == null)
            state.isRecommendationLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final canUseAI = ref.read(subscriptionProvider.notifier).canUseAI;
                        if (canUseAI) {
                          ref.read(homeViewModelProvider.notifier).getDailyRecommendation();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Günlük ücretsiz AI önerisi limitine ulaştınız. Sınırsız kullanım için Pro\'ya geçin.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ProPaywallScreen(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Bugünün Kombinini Öner'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                )
          else
            RecommendationPreview(recommendation: recommendation, wardrobeItems: wardrobeItems),
        ],
      ),
    );
  }
}
