import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/laundry_item.dart';

// ViewModel State
class LaundryState {
  final bool isLoading;
  final List<LaundryItem> items;
  final String? error;

  LaundryState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  LaundryState copyWith({
    bool? isLoading,
    List<LaundryItem>? items,
    String? error,
  }) {
    return LaundryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }

  List<LaundryItem> get needsWashItems =>
      items.where((i) => i.status == LaundryStatus.needsWash).toList();

  List<LaundryItem> get washingItems =>
      items.where((i) => i.status == LaundryStatus.washing).toList();

  List<LaundryItem> get cleanItems =>
      items.where((i) => i.status == LaundryStatus.clean).toList();
}

// ViewModel (Notifier)
class LaundryViewModel extends Notifier<LaundryState> {
  @override
  LaundryState build() {
    Future.microtask(() => loadItems());
    return LaundryState(isLoading: true);
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final mockData = [
        const LaundryItem(
          id: '1', name: 'Beyaz Keten Gömlek', category: 'Üst Giyim',
          wearCount: 3, maxWear: 3, icon: Icons.dry_cleaning_rounded,
          status: LaundryStatus.needsWash,
        ),
        const LaundryItem(
          id: '2', name: 'Siyah Kot Pantolon', category: 'Alt Giyim',
          wearCount: 5, maxWear: 5, icon: Icons.airline_seat_legroom_normal_rounded,
          status: LaundryStatus.needsWash,
        ),
        const LaundryItem(
          id: '3', name: 'Spor Tişört', category: 'Üst Giyim',
          wearCount: 1, maxWear: 1, icon: Icons.dry_cleaning_rounded,
          status: LaundryStatus.washing,
        ),
        const LaundryItem(
          id: '4', name: 'Açık Mavi Gömlek', category: 'Üst Giyim',
          wearCount: 0, maxWear: 3, icon: Icons.dry_cleaning_rounded,
          status: LaundryStatus.clean,
        ),
        const LaundryItem(
          id: '5', name: 'Gri Eşofman', category: 'Alt Giyim',
          wearCount: 0, maxWear: 2, icon: Icons.airline_seat_legroom_normal_rounded,
          status: LaundryStatus.clean,
        ),
        const LaundryItem(
          id: '6', name: 'Bordo Kazak', category: 'Üst Giyim',
          wearCount: 1, maxWear: 4, icon: Icons.dry_cleaning_rounded,
          status: LaundryStatus.clean,
        ),
      ];

      state = state.copyWith(isLoading: false, items: mockData);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void moveToWashing(String id) {
    final updated = state.items.map((item) {
      if (item.id == id) return item.copyWith(status: LaundryStatus.washing);
      return item;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void moveToClean(String id) {
    final updated = state.items.map((item) {
      if (item.id == id) return item.copyWith(status: LaundryStatus.clean, wearCount: 0);
      return item;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void moveToNeedsWash(String id) {
    final updated = state.items.map((item) {
      if (item.id == id) return item.copyWith(status: LaundryStatus.needsWash, wearCount: item.maxWear);
      return item;
    }).toList();
    state = state.copyWith(items: updated);
  }
}

// Global Provider
final laundryViewModelProvider = NotifierProvider<LaundryViewModel, LaundryState>(() {
  return LaundryViewModel();
});
