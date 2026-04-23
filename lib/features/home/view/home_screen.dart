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
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildWelcomeSection(context, homeState.userName),
                        const SizedBox(height: 28),
                        _buildSectionTitle(context, 'Yaklaşan Önemli Bilgiler'),
                        const SizedBox(height: 12),
                        _buildUpcomingInfo(
                          context,
                          ref,
                          laundryCount,
                          nextEventTitle,
                          nextEventTime,
                          nextEvent,
                        ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Favori Kombinler'),
                  const SizedBox(height: 12),
                  _buildFavoriteOutfits(context, ref, favoriteOutfits),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Bugün'),
                  const SizedBox(height: 12),
                  _buildTodayCard(context, ref, homeState),
                ]),
              ),
            ),
          ],
        ),
    );
  }


  Widget _buildWelcomeSection(BuildContext context, String userName) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merhaba, $userName',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bugün ne giyeceksin?',
          style: theme.textTheme.headlineMedium,
        ),
      ],
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
    return Column(
      children: [
        _InfoCard(
          icon: Icons.local_laundry_service_rounded,
          title: 'Yıkanması Gerekenler',
          subtitle: laundryCount > 0 
            ? '$laundryCount kıyafetin yıkanma vakti geldi.' 
            : 'Yıkanacak kıyafet yok.',
          color: Colors.blue,
          onTap: () {
            // Hijyen sekmesi index 4
            ref.read(mainNavIndexProvider.notifier).navigate(4);
          },
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.event_rounded,
          title: 'Yaklaşan Etkinlik',
          subtitle: '$nextEventTime $nextEventTitle',
          color: Colors.orange,
          onTap: nextEvent != null ? () {
            // Takvim sekmesi index 3, ilgili günü seç
            ref.read(styleCalendarViewModelProvider.notifier)
                .selectDay(nextEvent.date, nextEvent.date);
            ref.read(mainNavIndexProvider.notifier).navigate(3);
          } : () {},
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

    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
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

          return Container(
            width: 148,
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotoğraf bölümü
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: Colors.white, width: 1.5),
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
                                      top: 6,
                                      left: 6,
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
          );
        },
      ),
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

    if (weather == null) return const SizedBox.shrink();

    IconData weatherIcon = Icons.wb_sunny_rounded;
    Color weatherColor = Colors.orange;

    if (weather.condition == 'Yağmurlu') {
      weatherIcon = Icons.umbrella_rounded;
      weatherColor = Colors.blue;
    } else if (weather.condition == 'Bulutlu') {
      weatherIcon = Icons.cloud_rounded;
      weatherColor = Colors.grey;
    } else if (weather.condition == 'Karlı') {
      weatherIcon = Icons.ac_unit_rounded;
      weatherColor = Colors.lightBlueAccent;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: weatherColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(weatherIcon, color: weatherColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.city}, ${weather.temperature.toInt()}°C',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      weather.condition,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    weather.advice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          
          if (recommendation == null)
            state.isRecommendationLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center(
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(homeViewModelProvider.notifier).getDailyRecommendation(),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Bugünün Kombinini Öner'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Önerilen Kombin',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
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

              return Container(
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null 
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : _buildOutfitPlaceholder(theme),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          recommendation['description'] ?? 'Harika bir kombin!',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
    return Material(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

