import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gircik/features/subscription/viewmodel/subscription_viewmodel.dart';
import 'package:gircik/features/subscription/repository/subscription_repository.dart';
import 'package:gircik/data/models/subscription.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

void main() {
  late MockSubscriptionRepository mockSubscriptionRepository;
  late ProviderContainer container;

  setUp(() {
    mockSubscriptionRepository = MockSubscriptionRepository();
    when(() => mockSubscriptionRepository.getStatus()).thenAnswer((_) async => const Subscription(
      plan: SubscriptionPlan.free,
      clothingItemCount: 0,
      outfitCount: 0,
      aiUsagesToday: 0,
      calendarEventCount: 0,
    ));

    container = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(mockSubscriptionRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SubscriptionViewModel Tests', () {
    test('initial state loads status from repository', () async {
      container.read(subscriptionProvider);
      await Future.delayed(Duration.zero);
      
      final state = container.read(subscriptionProvider);
      expect(state.plan, SubscriptionPlan.free);
    });

    test('canAddClothing returns false when limit reached for free user', () async {
      when(() => mockSubscriptionRepository.getStatus()).thenAnswer((_) async => const Subscription(
        plan: SubscriptionPlan.free,
        clothingItemCount: 10, // maxClothingItems is 10
        outfitCount: 0,
        aiUsagesToday: 0,
        calendarEventCount: 0,
      ));
      
      final viewModel = container.read(subscriptionProvider.notifier);
      await Future.delayed(Duration.zero);
      
      expect(viewModel.canAddClothing, isFalse);
    });

    test('canAddClothing returns true for pro user regardless of count', () async {
      when(() => mockSubscriptionRepository.getStatus()).thenAnswer((_) async => const Subscription(
        plan: SubscriptionPlan.monthly, // Pro plan
        clothingItemCount: 100, // higher than free limit
        outfitCount: 0,
        aiUsagesToday: 0,
        calendarEventCount: 0,
      ));
      
      final viewModel = container.read(subscriptionProvider.notifier);
      await Future.delayed(Duration.zero);
      
      expect(viewModel.canAddClothing, isTrue);
    });

    test('incrementAIUsage calls repository to increment usage', () async {
      when(() => mockSubscriptionRepository.incrementUsage('ai_usages_today')).thenAnswer((_) async => const Subscription(
        plan: SubscriptionPlan.free,
        clothingItemCount: 0,
        outfitCount: 0,
        aiUsagesToday: 1,
        calendarEventCount: 0,
      ));
      
      final viewModel = container.read(subscriptionProvider.notifier);
      await Future.delayed(Duration.zero);
      
      viewModel.incrementAIUsage();
      
      verify(() => mockSubscriptionRepository.incrementUsage('ai_usages_today')).called(1);
    });
  });
}
