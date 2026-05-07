import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gircik/features/home/view/home_screen.dart';
import 'package:gircik/features/auth/repository/auth_repository.dart';
import 'package:gircik/features/laundry/repository/laundry_repository.dart';
import 'package:gircik/features/style_calendar/repository/calendar_repository.dart';
import 'package:gircik/core/services/weather_service.dart';
import 'package:gircik/features/outfits/repository/outfit_repository.dart';
import 'package:gircik/features/wardrobe/repository/clothing_repository.dart';
import 'package:gircik/features/subscription/repository/subscription_repository.dart';

import 'package:gircik/data/models/user.dart';
import 'package:gircik/data/models/subscription.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockLaundryRepository extends Mock implements LaundryRepository {}
class MockCalendarRepository extends Mock implements CalendarRepository {}
class MockWeatherService extends Mock implements WeatherService {}
class MockOutfitRepository extends Mock implements OutfitRepository {}
class MockClothingRepository extends Mock implements ClothingRepository {}
class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockLaundryRepository mockLaundryRepository;
  late MockCalendarRepository mockCalendarRepository;
  late MockWeatherService mockWeatherService;
  late MockOutfitRepository mockOutfitRepository;
  late MockClothingRepository mockClothingRepository;
  late MockSubscriptionRepository mockSubscriptionRepository;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockLaundryRepository = MockLaundryRepository();
    mockCalendarRepository = MockCalendarRepository();
    mockWeatherService = MockWeatherService();
    mockOutfitRepository = MockOutfitRepository();
    mockClothingRepository = MockClothingRepository();
    mockSubscriptionRepository = MockSubscriptionRepository();

    when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => User(id: '1', name: 'Test User', email: 'test@test.com'));
    when(() => mockLaundryRepository.getLaundryItems()).thenAnswer((_) async => []);
    when(() => mockCalendarRepository.getEvents()).thenAnswer((_) async => []);
    when(() => mockWeatherService.getCurrentWeather()).thenAnswer((_) async => WeatherInfo(temperature: 20, condition: 'Güneşli', city: 'İstanbul', advice: 'Giyin'));
    when(() => mockOutfitRepository.getOutfits()).thenAnswer((_) async => []);
    when(() => mockClothingRepository.getClothingItems()).thenAnswer((_) async => []);
    when(() => mockSubscriptionRepository.getStatus()).thenAnswer((_) async => const Subscription());
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        laundryRepositoryProvider.overrideWithValue(mockLaundryRepository),
        calendarRepositoryProvider.overrideWithValue(mockCalendarRepository),
        weatherServiceProvider.overrideWithValue(mockWeatherService),
        outfitRepositoryProvider.overrideWithValue(mockOutfitRepository),
        clothingRepositoryProvider.overrideWithValue(mockClothingRepository),
        subscriptionRepositoryProvider.overrideWithValue(mockSubscriptionRepository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: HomeScreen(),
        ),
      ),
    );
  }

  testWidgets('HomeScreen renders greeting and dashboard cards', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for all async calls to finish

    // Verify dashboard cards
    expect(find.text('Bugün'), findsOneWidget);
    expect(find.text('Güneşli'), findsWidgets); // Weather data mock
    expect(find.text('Yaklaşan Önemli Bilgiler'), findsOneWidget);
  });
}
