import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/features/laundry/repository/laundry_repository.dart';
import 'package:gircik/features/style_calendar/repository/calendar_repository.dart';
import 'package:gircik/core/services/weather_service.dart';
import 'package:gircik/features/outfits/repository/outfit_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ViewModel State
class HomeState {
  final bool isLoading;
  final String userName;
  final int laundryCount;
  final String nextEventTitle;
  final String nextEventTime;
  final WeatherInfo? weather;
  final Map<String, dynamic>? dailyRecommendation;
  final bool isRecommendationLoading;
  final String? error;

  HomeState({
    this.isLoading = false,
    this.userName = 'Kullanıcı',
    this.laundryCount = 0,
    this.nextEventTitle = 'Veri Yok',
    this.nextEventTime = '',
    this.weather,
    this.dailyRecommendation,
    this.isRecommendationLoading = false,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    String? userName,
    int? laundryCount,
    String? nextEventTitle,
    String? nextEventTime,
    WeatherInfo? weather,
    Map<String, dynamic>? dailyRecommendation,
    bool? isRecommendationLoading,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      laundryCount: laundryCount ?? this.laundryCount,
      nextEventTitle: nextEventTitle ?? this.nextEventTitle,
      nextEventTime: nextEventTime ?? this.nextEventTime,
      weather: weather ?? this.weather,
      dailyRecommendation: dailyRecommendation ?? this.dailyRecommendation,
      isRecommendationLoading: isRecommendationLoading ?? this.isRecommendationLoading,
      error: error,
    );
  }
}

// ViewModel (Notifier)
class HomeViewModel extends Notifier<HomeState> {
  late final AuthRepository _authRepo;
  late final LaundryRepository _laundryRepo;
  late final CalendarRepository _calendarRepo;
  late final WeatherService _weatherService;
  late final OutfitRepository _outfitRepo;

  @override
  HomeState build() {
    _authRepo = ref.watch(authRepositoryProvider);
    _laundryRepo = ref.watch(laundryRepositoryProvider);
    _calendarRepo = ref.watch(calendarRepositoryProvider);
    _weatherService = ref.watch(weatherServiceProvider);
    _outfitRepo = ref.watch(outfitRepositoryProvider);
    
    // Initial fetch when ViewModel is created
    Future.microtask(() => loadHomeData());
    return HomeState(isLoading: true);
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepo.getCurrentUser();
      final laundryItems = await _laundryRepo.getLaundryItems();
      final calendarEvents = await _calendarRepo.getEvents();
      final weather = await _weatherService.getCurrentWeather();

      final needsWashCount = laundryItems.where((i) => i.status.name == 'needsWash').length;
      
      String nextEventTitle = 'Yaklaşan etkinlik yok';
      String nextEventTime = '';
      
      final now = DateTime.now();
      final upcomingEvents = calendarEvents.where((e) => e.date.isAfter(now)).toList();
      if (upcomingEvents.isNotEmpty) {
        upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
        final nextEvent = upcomingEvents.first;
        nextEventTitle = nextEvent.title;
        
        final diff = nextEvent.date.difference(now);
        if (diff.inDays == 0) {
          nextEventTime = 'Bugün:';
        } else if (diff.inDays == 1) {
          nextEventTime = 'Yarın:';
        } else {
          nextEventTime = '\${diff.inDays} gün sonra:';
        }
      }

      state = state.copyWith(
        isLoading: false,
        userName: user.name,
        laundryCount: needsWashCount,
        nextEventTitle: nextEventTitle,
        nextEventTime: nextEventTime,
        weather: weather,
      );

      // Check cache after data is loaded
      await _checkAndLoadCache();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _checkAndLoadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = prefs.getString('daily_recommendation_cache');
    final cacheDate = prefs.getString('daily_recommendation_date');

    final today = DateTime.now().toIso8601String().split('T')[0];

    if (cacheData != null && cacheDate == today) {
      // Cache is valid for today
      try {
        final decoded = json.decode(cacheData);
        state = state.copyWith(dailyRecommendation: decoded as Map<String, dynamic>);
      } catch (e) {
        print('Cache parse error: $e');
        // If cache is corrupted, generate new one
        await getDailyRecommendation();
      }
    } else {
      // No valid cache, generate automatically
      await getDailyRecommendation();
    }
  }

  Future<void> _saveToCache(Map<String, dynamic> recommendation) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await prefs.setString('daily_recommendation_cache', json.encode(recommendation));
    await prefs.setString('daily_recommendation_date', today);
  }

  Future<void> getDailyRecommendation() async {
    if (state.weather == null) return;
    
    state = state.copyWith(isRecommendationLoading: true, error: null);
    try {
      // Mevsimi ayarla
      final month = DateTime.now().month;
      String season = 'İlkbahar';
      if (month >= 6 && month <= 8) season = 'Yaz';
      else if (month >= 9 && month <= 11) season = 'Sonbahar';
      else if (month == 12 || month <= 2) season = 'Kış';

      final recommendation = await _outfitRepo.generateAIOutfit(
        season: season,
        weather: state.weather!.condition,
        event: 'Günlük/Casual',
        style: 'Rahat',
      );
      
      // Save to cache
      await _saveToCache(recommendation);
      
      state = state.copyWith(isRecommendationLoading: false, dailyRecommendation: recommendation);
    } catch (e) {
      state = state.copyWith(isRecommendationLoading: false, error: e.toString());
    }
  }
}

// Global Provider
final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});

