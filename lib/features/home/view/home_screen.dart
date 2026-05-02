import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';
import 'package:gircik/features/wardrobe/viewmodel/wardrobe_viewmodel.dart';
import 'package:gircik/data/models/outfit_item.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:gircik/core/providers/navigation_provider.dart';
import 'package:gircik/core/constants/api_constants.dart';
import 'package:gircik/core/services/weather_service.dart';

import '../../subscription/view/pro_paywall_screen.dart';
import '../../subscription/viewmodel/subscription_viewmodel.dart';
import '../../travel/view/travel_assistant_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final laundryState = ref.watch(laundryViewModelProvider);
    final calendarState = ref.watch(styleCalendarViewModelProvider);
    final outfitsState = ref.watch(outfitsViewModelProvider);

    final laundryCount = laundryState.needsWashItems.length;

    final now = DateTime.now();
    // Sadece bugünden sonraki günleri göster (bugün dahil)
    final today = DateTime(now.year, now.month, now.day);
    final upcomingEvents = calendarState.events.where((e) {
      final eventDay = DateTime(e.date.year, e.date.month, e.date.day);
      return !eventDay.isBefore(today);
    }).toList();
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
    final nextEvent = upcomingEvents.isNotEmpty ? upcomingEvents.first : null;

    String nextEventTitle = nextEvent?.title ?? 'Yaklaşan etkinlik yok';
    String nextEventTime = '';
    if (nextEvent != null) {
      // Takvim günü farkını hesapla (saat bilgisi olmadan)
      final eventDay = DateTime(nextEvent.date.year, nextEvent.date.month, nextEvent.date.day);
      final dayDiff = eventDay.difference(today).inDays;
      if (dayDiff == 0) {
        nextEventTime = 'Bugün:';
      } else if (dayDiff == 1) {
        nextEventTime = 'Yarın:';
      } else {
        nextEventTime = '$dayDiff gün sonra:';
      }
    }

    final favoriteOutfits = outfitsState.outfits.where((o) => o.isFavorite).toList();

    return Scaffold(
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(homeViewModelProvider.notifier).loadHomeData(),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle(context, 'Yaklaşan Önemli Bilgiler'),
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 4,
                        child: _buildUpcomingInfo(
                          context,
                          ref,
                          laundryCount,
                          nextEventTitle,
                          nextEventTime,
                          nextEvent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context, 'Favori Kombinler'),
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 5,
                        child: _buildFavoriteOutfits(context, ref, favoriteOutfits),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle(context, 'Bugün'),
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 9,
                        child: _buildTodayCard(context, ref, homeState),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 15,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildUpcomingInfo(
    BuildContext context,
    WidgetRef ref,
    int laundryCount,
    String nextEventTitle,
    String nextEventTime,
    CalendarEvent? nextEvent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.local_laundry_service_rounded,
            title: 'Yıkanması Gerekenler',
            subtitle: laundryCount > 0 
              ? '$laundryCount kıyafet' 
              : 'Yok',
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              // Hijyen sekmesi index 5
              ref.read(mainNavIndexProvider.notifier).navigate(5);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.event_rounded,
            title: 'Yaklaşan Etkinlik',
            subtitle: nextEvent != null ? '$nextEventTime $nextEventTitle' : 'Yok',
            color: Theme.of(context).colorScheme.primary,
            onTap: nextEvent != null ? () {
              // Takvim sekmesi index 3, ilgili günü seç
              ref.read(styleCalendarViewModelProvider.notifier)
                  .selectDay(nextEvent.date, nextEvent.date);
              ref.read(mainNavIndexProvider.notifier).navigate(3);
            } : () {},
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteOutfits(BuildContext context, WidgetRef ref, List<OutfitItem> favorites) {
    final theme = Theme.of(context);
    final wardrobeItems = ref.watch(wardrobeViewModelProvider).items;

    if (favorites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Henüz favori kombininiz yok.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final outfit = favorites[index];

          // Kombindeki kıyafet resimlerini bul
          final outfitImages = outfit.items.map((link) {
            final item = wardrobeItems.where((w) => w.id == link.clothingItemId).firstOrNull;
            if (item?.imageUrl != null && item!.imageUrl!.isNotEmpty) {
              return item.imageUrl!.startsWith('http')
                  ? item.imageUrl!
                  : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}';
            }
            return null;
          }).where((url) => url != null).cast<String>().toList();

          return AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 22,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotoğraf bölümü
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: outfitImages.isNotEmpty
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Arka plan: ilk kıyafet
                                    Image.network(
                                      outfitImages[0],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildOutfitPlaceholder(theme),
                                    ),
                                    // Sağ alt köşede mini üst üste fotoğraflar
                                    if (outfitImages.length > 1)
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Row(
                                          children: outfitImages
                                              .skip(1)
                                              .take(2)
                                              .map(
                                                (url) => Container(
                                                  margin: const EdgeInsets.only(left: 4),
                                                  width: 30,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.surfaceContainerHighest,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: 0.2),
                                                        blurRadius: 4,
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(5),
                                                    child: Image.network(url, fit: BoxFit.cover),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    // Favori ikonlu üst sol rozet
                                    Positioned(
                                      top: 3,
                                      left: 3,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade500,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.favorite_rounded, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              : _buildOutfitPlaceholder(theme),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        outfit.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        outfit.style,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          );
        },
      );
  }

  Widget _buildOutfitPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 40,
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context, WidgetRef ref, HomeState state) {
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
      padding: const EdgeInsets.all(12), // Daha da küçültüldü
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(20), // Daha da küçültüldü
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
                    padding: const EdgeInsets.all(6), // Daha da küçültüldü
                    decoration: BoxDecoration(
                      color: weatherColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(weatherIcon, color: weatherColor, size: 20), // Daha da küçültüldü
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.city,
                        style: theme.textTheme.titleSmall?.copyWith( // Daha da küçültüldü
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: theme.textTheme.labelSmall?.copyWith( // Daha da küçültüldü
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
                style: theme.textTheme.headlineSmall?.copyWith( // Daha da küçültüldü
                  fontWeight: FontWeight.w300,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Boşluklar azaltıldı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Daha da küçültüldü
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, size: 14, color: theme.colorScheme.primary), // Daha da küçültüldü
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weather.advice,
                    style: theme.textTheme.labelSmall?.copyWith( // Daha da küçültüldü
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
            _buildRecommendationPreview(context, ref, recommendation, wardrobeItems),
        ],
      ),
    );
  }

  Widget _buildRecommendationPreview(
    BuildContext context, 
    WidgetRef ref, 
    Map<String, dynamic> recommendation,
    List<dynamic> wardrobeItems
  ) {
    final theme = Theme.of(context);
    
    // ID'leri topla
    final ids = [
      recommendation['top_id'],
      recommendation['bottom_id'],
      recommendation['outerwear_id'],
      recommendation['shoes_id'],
      recommendation['shawl_id'],
    ].where((id) => id != null).cast<String>().toList();

    final matchedClothes = ids.map((id) {
      return wardrobeItems.where((w) => w.id == id).firstOrNull;
    }).where((item) => item != null).toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Önerilen Kombin',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: matchedClothes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = matchedClothes[index];
                final String? imageUrl = item?.imageUrl != null && item!.imageUrl!.isNotEmpty
                    ? (item.imageUrl!.startsWith('http') 
                        ? item.imageUrl! 
                        : '${ApiConstants.baseUrl.replaceAll('/api', '')}${item.imageUrl}')
                    : null;

                return AspectRatio(
                  aspectRatio: 0.75, // Biraz dikey dikdörtgen daha şık durur
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null 
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : _buildOutfitPlaceholder(theme),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recommendation['description'] ?? 'Harika bir kombin!',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ?? theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(flex: 1),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

