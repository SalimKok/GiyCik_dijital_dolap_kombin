import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/subscription.dart';
import 'package:gircik/features/subscription/repository/subscription_repository.dart';

class SubscriptionViewModel extends Notifier<Subscription> {
  late SubscriptionRepository _repository;

  @override
  Subscription build() {
    _repository = ref.watch(subscriptionRepositoryProvider);
    Future.microtask(() => loadStatus());
    
    return const Subscription(
      plan: SubscriptionPlan.free,
      clothingItemCount: 0,
      outfitCount: 0,
      aiUsagesToday: 0,
      calendarEventCount: 0,
    );
  }

  Future<void> loadStatus() async {
    try {
      final sub = await _repository.getStatus();
      state = sub;
    } catch (e) {
      // Failed to load, keep default
    }
  }

  Future<bool> purchasePlan(SubscriptionPlan plan) async {
    try {
      String planStr = plan == SubscriptionPlan.monthly ? 'monthly' : 'yearly';
      final updatedSub = await _repository.purchase(planStr);
      state = updatedSub;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> cancelSubscription() async {
    try {
      final updatedSub = await _repository.cancel();
      state = updatedSub;
    } catch (e) {
    }
  }

  Future<void> _incrementMetric(String metric) async {
    try {
      final updatedSub = await _repository.incrementUsage(metric);
      state = updatedSub;
    } catch (e) {
    }
  }

  // --- Limit Kontrolleri ---

  bool get canAddClothing => state.isPro || state.clothingItemCount < FreeLimits.maxClothingItems;
  bool get canAddOutfit => state.isPro || state.outfitCount < FreeLimits.maxOutfits;
  bool get canUseAI => state.isPro || state.aiUsagesToday < FreeLimits.maxTotalAIRecommendations;
  bool get canAddEvent => state.isPro || state.calendarEventCount < FreeLimits.maxCalendarEvents;

  // --- Sayaç Güncellemeleri ---

  void incrementClothingCount() {
    _incrementMetric('clothing_item_count');
  }

  void incrementOutfitCount() {
    _incrementMetric('outfit_count');
  }

  void incrementAIUsage() {
    _incrementMetric('ai_usages_today');
  }

  void incrementCalendarEventCount() {
    _incrementMetric('calendar_event_count');
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionViewModel, Subscription>(() {
  return SubscriptionViewModel();
});

