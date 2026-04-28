/// Abonelik plan tipleri.
enum SubscriptionPlan {
  free,
  monthly,
  yearly,
}

/// Ücretsiz kullanıcılar için kullanım sınırları.
class FreeLimits {
  static const int maxClothingItems = 10;
  static const int maxOutfits = 10;
  static const int maxTotalAIRecommendations = 10;
  static const int maxCalendarEvents = 10;
}

/// Kullanıcının abonelik durumunu temsil eder.
class Subscription {
  final SubscriptionPlan plan;
  final int clothingItemCount;
  final int outfitCount;
  final int aiUsagesToday;
  final int calendarEventCount;

  const Subscription({
    this.plan = SubscriptionPlan.free,
    this.clothingItemCount = 0,
    this.outfitCount = 0,
    this.aiUsagesToday = 0,
    this.calendarEventCount = 0,
  });

  bool get isPro => plan != SubscriptionPlan.free;

  bool get canAddClothing =>
      isPro || clothingItemCount < FreeLimits.maxClothingItems;

  bool get canCreateOutfit =>
      isPro || outfitCount < FreeLimits.maxOutfits;

  bool get canUseAI =>
      isPro || aiUsagesToday < FreeLimits.maxTotalAIRecommendations;

  bool get canAddCalendarEvent =>
      isPro || calendarEventCount < FreeLimits.maxCalendarEvents;

  int get remainingClothing =>
      isPro ? -1 : FreeLimits.maxClothingItems - clothingItemCount;

  int get remainingOutfits =>
      isPro ? -1 : FreeLimits.maxOutfits - outfitCount;

  int get remainingAI =>
      isPro ? -1 : FreeLimits.maxTotalAIRecommendations - aiUsagesToday;

  int get remainingCalendarEvents =>
      isPro ? -1 : FreeLimits.maxCalendarEvents - calendarEventCount;

  String get planDisplayName {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Ücretsiz';
      case SubscriptionPlan.monthly:
        return 'Pro Aylık';
      case SubscriptionPlan.yearly:
        return 'Pro Yıllık';
    }
  }

  Subscription copyWith({
    SubscriptionPlan? plan,
    int? clothingItemCount,
    int? outfitCount,
    int? aiUsagesToday,
    int? calendarEventCount,
  }) {
    return Subscription(
      plan: plan ?? this.plan,
      clothingItemCount: clothingItemCount ?? this.clothingItemCount,
      outfitCount: outfitCount ?? this.outfitCount,
      aiUsagesToday: aiUsagesToday ?? this.aiUsagesToday,
      calendarEventCount: calendarEventCount ?? this.calendarEventCount,
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    SubscriptionPlan parsedPlan = SubscriptionPlan.free;
    if (json['plan'] == 'monthly') parsedPlan = SubscriptionPlan.monthly;
    if (json['plan'] == 'yearly') parsedPlan = SubscriptionPlan.yearly;

    return Subscription(
      plan: parsedPlan,
      clothingItemCount: json['clothing_item_count'] as int? ?? 0,
      outfitCount: json['outfit_count'] as int? ?? 0,
      aiUsagesToday: json['ai_usages_today'] as int? ?? 0,
      calendarEventCount: json['calendar_event_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    String planStr = 'free';
    if (plan == SubscriptionPlan.monthly) planStr = 'monthly';
    if (plan == SubscriptionPlan.yearly) planStr = 'yearly';

    return {
      'plan': planStr,
      'clothing_item_count': clothingItemCount,
      'outfit_count': outfitCount,
      'ai_usages_today': aiUsagesToday,
      'calendar_event_count': calendarEventCount,
    };
  }
}
