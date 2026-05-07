import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gircik/features/home/viewmodel/home_viewmodel.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/features/laundry/repository/laundry_repository.dart';
import 'package:gircik/features/style_calendar/repository/calendar_repository.dart';
import 'package:gircik/core/services/weather_service.dart';
import 'package:gircik/features/outfits/repository/outfit_repository.dart';
import 'package:gircik/data/models/user.dart';
import 'package:gircik/data/models/laundry_item.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/data/models/calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:gircik/data/models/laundry_item.dart';
import 'package:gircik/data/models/clothing_item.dart';
import 'package:gircik/data/models/calendar_event.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockLaundryRepository extends Mock implements LaundryRepository {}
class MockCalendarRepository extends Mock implements CalendarRepository {}
class MockWeatherService extends Mock implements WeatherService {}
class MockOutfitRepository extends Mock implements OutfitRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockLaundryRepository mockLaundryRepository;
  late MockCalendarRepository mockCalendarRepository;
  late MockWeatherService mockWeatherService;
  late MockOutfitRepository mockOutfitRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockLaundryRepository = MockLaundryRepository();
    mockCalendarRepository = MockCalendarRepository();
    mockWeatherService = MockWeatherService();
    mockOutfitRepository = MockOutfitRepository();
    
    SharedPreferences.setMockInitialValues({});

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        laundryRepositoryProvider.overrideWithValue(mockLaundryRepository),
        calendarRepositoryProvider.overrideWithValue(mockCalendarRepository),
        weatherServiceProvider.overrideWithValue(mockWeatherService),
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('HomeViewModel Tests', () {
    test('loadHomeData populates user name, laundry count, and events', () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(id: '1', name: 'Test User', email: 'test@test.com'));
          
      final laundryItem = LaundryItem(
        id: 'L1',
        name: 'Shirt',
        category: 'Top',
        clothingItemId: '1',
        wearCount: 0,
        maxWear: 3,
        icon: Icons.checkroom,
        status: LaundryStatus.needsWash,
      );
      when(() => mockLaundryRepository.getLaundryItems())
          .thenAnswer((_) async => [laundryItem]);

      final event = CalendarEvent(
        id: 'E1',
        title: 'Mülakat',
        date: DateTime.now().add(const Duration(hours: 25)),
      );
      when(() => mockCalendarRepository.getEvents())
          .thenAnswer((_) async => [event]);
          
      when(() => mockWeatherService.getCurrentWeather())
          .thenAnswer((_) async => WeatherInfo(temperature: 20, condition: 'Güneşli', city: 'İstanbul', advice: 'Giyin'));

      // Microtask runs loadHomeData
      container.read(homeViewModelProvider);
      
      // Allow async operations to finish
      await Future.delayed(const Duration(milliseconds: 100)); 
      
      final state = container.read(homeViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.userName, 'Test User');
      expect(state.laundryCount, 1);
      expect(state.nextEventTitle, 'Mülakat');
      expect(state.nextEventTime, 'Yarın:');
      expect(state.weather?.city, 'İstanbul');
    });
  });
}
