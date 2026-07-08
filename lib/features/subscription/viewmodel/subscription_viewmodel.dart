import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/subscription.dart';
import 'package:gircik/features/subscription/repository/subscription_repository.dart';
import 'package:gircik/core/services/revenue_cat_service.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint("Load status error: $e");
    }
  }

  Future<bool> purchasePackage(dynamic package) async {
    // Note: Use dynamic to avoid importing purchases_flutter everywhere, or import it.
    // In this implementation, we will assume pro_paywall_screen passes the package.
    try {
      final isPro = await RevenueCatService.purchasePackage(package);
      if (isPro) {
        // Optimistically update the state
        state = state.copyWith(
          plan: SubscriptionPlan.monthly, // Or yearly based on package
        );
        // Refresh from backend to sync
        loadStatus();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Purchase error: $e");
      return false;
    }
  }

  Future<void> cancelSubscription() async {
    try {
      final updatedSub = await _repository.cancel();
      state = updatedSub;
    } catch (e) {
      debugPrint("Cancel sub error: $e");
    }
  }

  Future<void> _incrementMetric(String metric) async {
    try {
      final updatedSub = await _repository.incrementUsage(metric);
      state = updatedSub;
    } catch (e) {
      debugPrint("Increment metric error: $e");
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

