import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'package:gircik/features/wardrobe/view/wardrobe_screen.dart';
import 'package:gircik/features/wardrobe/repository/clothing_repository.dart';
import 'package:gircik/features/laundry/repository/laundry_repository.dart';
import 'package:gircik/features/subscription/repository/subscription_repository.dart';
import 'package:gircik/data/models/subscription.dart';

class MockClothingRepository extends Mock implements ClothingRepository {}
class MockLaundryRepository extends Mock implements LaundryRepository {}
class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

void main() {
  late MockClothingRepository mockClothingRepository;
  late MockLaundryRepository mockLaundryRepository;
  late MockSubscriptionRepository mockSubscriptionRepository;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    mockClothingRepository = MockClothingRepository();
    mockLaundryRepository = MockLaundryRepository();
    mockSubscriptionRepository = MockSubscriptionRepository();

    when(() => mockClothingRepository.getClothingItems()).thenAnswer((_) async => []);
    when(() => mockLaundryRepository.getLaundryItems()).thenAnswer((_) async => []);
    when(() => mockSubscriptionRepository.getStatus()).thenAnswer((_) async => const Subscription());
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        clothingRepositoryProvider.overrideWithValue(mockClothingRepository),
        laundryRepositoryProvider.overrideWithValue(mockLaundryRepository),
        subscriptionRepositoryProvider.overrideWithValue(mockSubscriptionRepository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: WardrobeScreen(),
        ),
      ),
    );
  }

  testWidgets('WardrobeScreen renders item count and add button', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('0 parça'), findsOneWidget);
      expect(find.text('Yeni kıyafet ekle'), findsOneWidget);
    });
  });

  testWidgets('WardrobeScreen FAB responds to tap', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();
      
      // Just verifying that it doesn't crash on navigating with 0 items (free limits ok)
      expect(find.text('Yeni kıyafet ekle'), findsNothing); // we navigated away
    });
  });
}
