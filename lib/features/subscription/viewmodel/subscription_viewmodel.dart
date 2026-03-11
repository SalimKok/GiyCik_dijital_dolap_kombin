import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/subscription.dart';

class SubscriptionViewModel extends Notifier<Subscription> {
  @override
  Subscription build() {
    // Varsayılan: ücretsiz plan, mock kullanım sayıları
    return const Subscription(
      plan: SubscriptionPlan.free,
      clothingItemCount: 12,
      outfitCount: 3,
      aiUsagesToday: 1,
      calendarEventCount: 4,
    );
  }

  /// Pro plana yükselt (mock — gerçek IAP sonra eklenecek).
  Future<void> purchasePlan(SubscriptionPlan plan) async {
    // Ödeme simülasyonu
    await Future<void>.delayed(const Duration(seconds: 1));
    state = state.copyWith(plan: plan);
  }

  /// Pro'dan geri dön (iptal).
  void cancelSubscription() {
    state = state.copyWith(plan: SubscriptionPlan.free);
  }

  /// Kıyafet ekleme sayacını artır.
  void incrementClothingCount() {
    state = state.copyWith(clothingItemCount: state.clothingItemCount + 1);
  }

  /// Kombin sayacını artır.
  void incrementOutfitCount() {
    state = state.copyWith(outfitCount: state.outfitCount + 1);
  }

  /// AI kullanım sayacını artır.
  void incrementAIUsage() {
    state = state.copyWith(aiUsagesToday: state.aiUsagesToday + 1);
  }

  /// Takvim etkinlik sayacını artır.
  void incrementCalendarEventCount() {
    state = state.copyWith(calendarEventCount: state.calendarEventCount + 1);
  }
}

final subscriptionProvider =
    NotifierProvider<SubscriptionViewModel, Subscription>(() {
  return SubscriptionViewModel();
});
