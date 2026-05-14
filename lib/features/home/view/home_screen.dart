import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';
import 'package:gircik/features/laundry/viewmodel/laundry_viewmodel.dart';
import 'package:gircik/features/style_calendar/viewmodel/style_calendar_viewmodel.dart';
import 'package:gircik/features/outfits/viewmodel/outfits_viewmodel.dart';

import 'package:gircik/features/home/view/widgets/home_section_title.dart';
import 'package:gircik/features/home/view/widgets/upcoming_info_row.dart';
import 'package:gircik/features/home/view/widgets/favorite_outfits_list.dart';
import 'package:gircik/features/home/view/widgets/today_weather_card.dart';

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
                      const HomeSectionTitle(title: 'Yaklaşan Önemli Bilgiler'),
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 4,
                        child: UpcomingInfoRow(
                          laundryCount: laundryCount,
                          nextEventTitle: nextEventTitle,
                          nextEventTime: nextEventTime,
                          nextEvent: nextEvent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const HomeSectionTitle(title: 'Favori Kombinler'),
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 5,
                        child: FavoriteOutfitsList(favorites: favoriteOutfits),
                      ),
                      const SizedBox(height: 16),
                      const HomeSectionTitle(title: 'Bugün'),
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 9,
                        child: TodayWeatherCard(state: homeState),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
